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
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
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
          error: (error, _) => LoadError(
            message: error is ApiException ? error.message : 'Could not load your profile.',
            onRetry: () => ref.invalidate(profileControllerProvider),
          ),
        ),
      ),
    );
  }
}

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
        const SizedBox(height: AppSpacing.lg),
        _RecoveryCodeCard(hasCode: profile.hasRecoveryCode),
        const SizedBox(height: AppSpacing.xxxl),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
          label: const Text('Log out'),
        ),
        const SizedBox(height: AppSpacing.md),
        const _DeleteAccountButton(),
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
      if (mounted) showError(context, error);
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
          label: profile.profilePictureUrl == null ? 'Change profile photo' : 'View profile photo',
          child: GestureDetector(
            onTap: _busy
                ? null
                : profile.profilePictureUrl == null
                    ? _openPhotoSheet
                    : () => _openPreview(profile),
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
                    child: Hero(
                      tag: _pictureHero,
                      child: ProfileAvatar(
                        initial: profile.initial,
                        pictureUrl: profile.profilePictureUrl,
                        size: 100,
                      ),
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
                  child: Semantics(
                    button: true,
                    label: 'Change profile photo',
                    child: GestureDetector(
                      onTap: _busy ? null : _openPhotoSheet,
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
        TextButton.icon(
          onPressed: _busy ? null : _openPhotoSheet,
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: Text(profile.profilePictureUrl == null ? 'Add photo' : 'Change photo'),
        ),
      ],
    );
  }

  void _openPreview(Profile profile) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) => _PicturePreview(profile: profile),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

const _pictureHero = 'profile-picture';

/// The profile picture full screen. Pinch or double-tap to zoom.
class _PicturePreview extends ConsumerStatefulWidget {
  const _PicturePreview({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_PicturePreview> createState() => _PicturePreviewState();
}

class _PicturePreviewState extends ConsumerState<_PicturePreview> {
  final _zoom = TransformationController();

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _toggleZoom(TapDownDetails details) {
    if (_zoom.value.getMaxScaleOnAxis() > 1) {
      _zoom.value = Matrix4.identity();
    } else {
      final point = details.localPosition;
      _zoom.value = Matrix4.identity()
        ..translateByDouble(-point.dx, -point.dy, 0, 1)
        ..scaleByDouble(2.5, 2.5, 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = ref.watch(profilePictureProvider(widget.profile.profilePictureUrl!)).value;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: bytes == null
            ? const CircularProgressIndicator(color: AppColors.accent)
            : GestureDetector(
                onDoubleTapDown: _toggleZoom,
                onDoubleTap: () {},
                child: InteractiveViewer(
                  transformationController: _zoom,
                  maxScale: 5,
                  child: Hero(
                    tag: _pictureHero,
                    child: Image.memory(bytes, fit: BoxFit.contain, semanticLabel: 'Profile photo'),
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------- recovery code and account

/// Asks for the password again before something that matters. Returns null when cancelled.
Future<String?> _askPassword(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
  bool danger = false,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: AppText.heading),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: AppText.secondary),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Password'),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.black) : null,
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: Text(action),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

class _RecoveryCodeCard extends ConsumerStatefulWidget {
  const _RecoveryCodeCard({required this.hasCode});

  final bool hasCode;

  @override
  ConsumerState<_RecoveryCodeCard> createState() => _RecoveryCodeCardState();
}

class _RecoveryCodeCardState extends ConsumerState<_RecoveryCodeCard> {
  bool _busy = false;

  Future<void> _create() async {
    final password = await _askPassword(
      context,
      title: 'New recovery code',
      message: 'Your old code will stop working. Enter your password to continue.',
      action: 'Create code',
    );
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(profileControllerProvider.notifier).createRecoveryCode(password);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recovery code', style: AppText.secondary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.hasCode
                ? 'You can reset a forgotten password with your recovery code. Lost it? Create a new one.'
                : "You don't have a recovery code yet. Without one, a forgotten password means a lost account.",
            style: AppText.body.copyWith(color: widget.hasCode ? AppColors.textSecondary : AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.md),
          LoadingButton(
            label: widget.hasCode ? 'Create a new code' : 'Create a recovery code',
            loading: _busy,
            onPressed: _create,
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountButton extends ConsumerStatefulWidget {
  const _DeleteAccountButton();

  @override
  ConsumerState<_DeleteAccountButton> createState() => _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends ConsumerState<_DeleteAccountButton> {
  bool _busy = false;

  Future<void> _delete() async {
    final password = await _askPassword(
      context,
      title: 'Delete your account?',
      message: 'This deletes your plans, workouts, weights and photo for good. It can\'t be undone. '
          'Enter your password to confirm.',
      action: 'Delete',
      danger: true,
    );
    if (password == null || password.isEmpty || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(profileControllerProvider.notifier).deleteAccount(password);
      // the router is on the login screen now
      messenger.showSnackBar(const SnackBar(content: Text('Your account was deleted.')));
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _busy ? null : _delete,
      icon: _busy
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.delete_forever_outlined, color: AppColors.danger),
      label: Text('Delete account', style: AppText.body.copyWith(color: AppColors.danger)),
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
            onPressed: () => showWeightSheet(context, current: weightKg),
            child: Text(weightKg == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}

/// Add today's body weight (also used by the Progress tab).
Future<void> showWeightSheet(BuildContext context, {double? current}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _WeightSheet(current: current),
  );
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
      if (mounted) showError(context, error);
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
      if (mounted) showError(context, error);
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
