import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import '../domain/profile.dart';
import 'widgets/profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile', style: AppText.heading)),
      body: SafeArea(
        child: profile.when(
          data: (profile) => _ProfileBody(profile: profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadError(
            message: error is ApiException ? error.message : 'Could not load your profile.',
            onRetry: () => ref.invalidate(profileControllerProvider),
          ),
        ),
      ),
    );
  }
}

/// Shows the API error message in a snackbar.
void _showError(BuildContext context, Object error) {
  final message = error is ApiException ? error.message : 'Something went wrong. Please try again.';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String formatKg(double kg) => kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : '$kg';

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
      children: [
        _Header(profile: profile),
        const SizedBox(height: AppSpacing.xxl),
        _WeightCard(weightKg: profile.currentWeightKg),
        const SizedBox(height: AppSpacing.lg),
        _BioCard(bio: profile.bio),
        const SizedBox(height: AppSpacing.xxxl),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
          label: const Text('Log out'),
        ),
      ].animate(interval: 50.ms).fadeIn(duration: 260.ms).slideY(begin: 0.05, end: 0),
    );
  }
}

// ---------------------------------------------------------------- header + photo

class _Header extends ConsumerStatefulWidget {
  const _Header({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    // resized on the device: faster upload and always under the API's 5 MB limit
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return; // the user cancelled

    await _run(() => ref.read(profileControllerProvider.notifier).uploadPicture(image));
  }

  void _openPhotoSheet() {
    final hasPicture = widget.profile.profilePictureUrl != null;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        void close() => Navigator.of(sheetContext).pop();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
                  title: const Text('Choose from gallery', style: AppText.body),
                  onTap: () {
                    close();
                    _pick(ImageSource.gallery);
                  },
                ),
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined, color: AppColors.accent),
                    title: const Text('Take a photo', style: AppText.body),
                    onTap: () {
                      close();
                      _pick(ImageSource.camera);
                    },
                  ),
                if (hasPicture)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                    title: Text('Remove photo', style: AppText.body.copyWith(color: AppColors.danger)),
                    onTap: () {
                      close();
                      _run(() => ref.read(profileControllerProvider.notifier).removePicture());
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Column(
      children: [
        Semantics(
          button: true,
          label: 'Change profile photo',
          child: GestureDetector(
            onTap: _busy ? null : _openPhotoSheet,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // gradient ring around the photo
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.signatureGradient,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    child: ProfileAvatar(
                      initial: profile.initial,
                      imageUrl: profile.pictureFullUrl,
                      size: 100,
                    ),
                  ),
                ),
                if (_busy)
                  const SizedBox.square(
                    dimension: 112,
                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.button,
                      border: Border.all(color: AppColors.background, width: 3),
                    ),
                    child: const Icon(Icons.photo_camera_rounded, size: 17, color: AppColors.onButton),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(profile.username, style: AppText.title),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Member since ${DateFormat.yMMMM().format(profile.createdAt.toLocal())}',
          style: AppText.secondary,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- body weight

class _WeightCard extends ConsumerWidget {
  const _WeightCard({required this.weightKg});

  final double? weightKg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Body weight', style: AppText.secondary),
                const SizedBox(height: AppSpacing.sm),
                if (weightKg != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(formatKg(weightKg!), style: AppText.display.copyWith(fontSize: 40)),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('kg', style: AppText.secondary),
                    ],
                  )
                else
                  Text(
                    'Add your weight so we can estimate the calories you burn.',
                    style: AppText.body.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => _WeightSheet(current: weightKg),
            ),
            child: Text(weightKg == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _WeightSheet extends ConsumerStatefulWidget {
  const _WeightSheet({required this.current});

  final double? current;

  @override
  ConsumerState<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<_WeightSheet> {
  late final _controller = TextEditingController(
    text: widget.current == null ? '' : formatKg(widget.current!),
  );
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // same limits as the API (BodyWeightEntry check constraint)
  static const _min = 20.0;
  static const _max = 400.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final weight = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (weight == null) return 'Enter a number, e.g. 78.5';
    if (weight < _min || weight > _max) return 'Between ${_min.toInt()} and ${_max.toInt()} kg';
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final weight = double.parse(_controller.text.replaceAll(',', '.'));
      await ref.read(profileControllerProvider.notifier).addBodyWeight(weight);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // stays above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Today's weight", style: AppText.heading),
                const SizedBox(height: AppSpacing.xs),
                const Text('We keep every entry, so you can follow the trend.', style: AppText.secondary),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  style: AppText.number,
                  validator: _validate,
                  onFieldSubmitted: (_) => _save(),
                  decoration: const InputDecoration(labelText: 'Weight', suffixText: 'kg'),
                ),
                const SizedBox(height: AppSpacing.xl),
                LoadingButton(label: 'Save', loading: _saving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- bio

class _BioCard extends ConsumerStatefulWidget {
  const _BioCard({required this.bio});

  final String? bio;

  @override
  ConsumerState<_BioCard> createState() => _BioCardState();
}

class _BioCardState extends ConsumerState<_BioCard> {
  late final _controller = TextEditingController(text: widget.bio ?? '');
  bool _saving = false;

  static const _maxLength = 500; // same as the API

  bool get _changed => _controller.text.trim() != (widget.bio ?? '');

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).updateBio(_controller.text);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Bio saved')));
      }
    } catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Bio', style: AppText.secondary),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            maxLength: _maxLength,
            style: AppText.body,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Your goals, your favorite lift, anything…',
              fillColor: AppColors.surface2,
            ),
          ),
          // the save button only appears when there is something to save
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _changed
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: LoadingButton(label: 'Save bio', loading: _saving, onPressed: _save),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- shared bits

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textTertiary, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppText.secondary, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
