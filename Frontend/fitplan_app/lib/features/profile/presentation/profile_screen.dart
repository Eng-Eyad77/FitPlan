import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/widgets/email_code.dart';
import '../application/profile_controller.dart';
import '../domain/profile.dart';
import 'widgets/profile_avatar.dart';
import '../../../l10n/l10n.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile, style: AppText.heading)),
      body: SafeArea(
        child: profile.when(
          data: (profile) => _ProfileBody(profile: profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => LoadError(
            message: error is ApiException ? error.message : l10n.couldNotLoadProfile,
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
        _EmailCard(email: profile.email),
        const SizedBox(height: AppSpacing.lg),
        const _LanguageCard(),
        const SizedBox(height: AppSpacing.xxxl),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
          label: Text(l10n.logOut),
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
                  title: Text(l10n.chooseFromGallery, style: AppText.body),
                  onTap: () {
                    close();
                    _pick(ImageSource.gallery);
                  },
                ),
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined, color: AppColors.accent),
                    title: Text(l10n.takePhoto, style: AppText.body),
                    onTap: () {
                      close();
                      _pick(ImageSource.camera);
                    },
                  ),
                if (hasPicture)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                    title: Text(l10n.removePhoto, style: AppText.body.copyWith(color: AppColors.danger)),
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
          label: profile.profilePictureUrl == null ? l10n.changeProfilePhoto : l10n.viewProfilePhoto,
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
                    label: l10n.changeProfilePhoto,
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
          l10n.memberSince(DateFormat.yMMMM().format(profile.createdAt.toLocal())),
          style: AppText.secondary,
        ),
        TextButton.icon(
          onPressed: _busy ? null : _openPhotoSheet,
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: Text(profile.profilePictureUrl == null ? l10n.addPhoto : l10n.changePhoto),
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
          tooltip: l10n.close,
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
                    child: Image.memory(bytes, fit: BoxFit.contain, semanticLabel: l10n.profilePhoto),
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------- email and account

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
            decoration: InputDecoration(labelText: l10n.password),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.black) : null,
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: Text(action),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

/// The account's email, and changing it (D18): the new address and the password, then the code
/// sent to the new address. The old address is told by the server.
class _EmailCard extends ConsumerStatefulWidget {
  const _EmailCard({required this.email});

  final String email;

  @override
  ConsumerState<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends ConsumerState<_EmailCard> {
  bool _busy = false;

  Future<void> _change() async {
    final request = await showDialog<({String email, String password})>(
      context: context,
      builder: (_) => const _NewEmailDialog(),
    );
    if (request == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(profileControllerProvider.notifier).sendEmailChangeCode(request.email, request.password);
    } catch (error) {
      if (mounted) showError(context, error);
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;

    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EmailCodeDialog(email: request.email),
    );
    if (changed == true && mounted) showMessage(context, l10n.emailChanged);
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.email, style: AppText.secondary),
          const SizedBox(height: AppSpacing.sm),
          Text(widget.email, style: AppText.body, textDirection: TextDirection.ltr),
          const SizedBox(height: AppSpacing.md),
          LoadingButton(label: l10n.changeEmail, loading: _busy, onPressed: _change),
        ],
      ),
    );
  }
}

class _NewEmailDialog extends StatefulWidget {
  const _NewEmailDialog();

  @override
  State<_NewEmailDialog> createState() => _NewEmailDialogState();
}

class _NewEmailDialogState extends State<_NewEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((email: _email.text.trim(), password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l10n.changeEmail, style: AppText.heading),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.changeEmailBody, style: AppText.secondary),
            const SizedBox(height: AppSpacing.lg),
            EmailField(controller: _email, label: l10n.newEmail, newEmail: true),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(labelText: l10n.password),
              validator: (value) => (value == null || value.isEmpty) ? l10n.enterPassword : null,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.sendCode)),
      ],
    );
  }
}

/// Stays open on a wrong code, so the user can try again without asking for a new one.
class _EmailCodeDialog extends ConsumerStatefulWidget {
  const _EmailCodeDialog({required this.email});

  final String email;

  @override
  ConsumerState<_EmailCodeDialog> createState() => _EmailCodeDialogState();
}

class _EmailCodeDialogState extends ConsumerState<_EmailCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(profileControllerProvider.notifier).confirmEmailChange(_code.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l10n.enterCodeTitle, style: AppText.heading),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.codeSentTo(signed(widget.email)), style: AppText.secondary),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.checkSpam, style: AppText.caption),
            const SizedBox(height: AppSpacing.lg),
            EmailCodeField(controller: _code, onSubmitted: (_) => _confirm()),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: AppText.secondary.copyWith(color: AppColors.danger)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        FilledButton(onPressed: _busy ? null : _confirm, child: Text(l10n.confirm)),
      ],
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
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountBody,
      action: l10n.delete,
      danger: true,
    );
    if (password == null || password.isEmpty || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(profileControllerProvider.notifier).deleteAccount(password);
      // the router is on the login screen now
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
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
      label: Text(l10n.deleteAccount, style: AppText.body.copyWith(color: AppColors.danger)),
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
                Text(l10n.bodyWeight, style: AppText.secondary),
                const SizedBox(height: AppSpacing.sm),
                if (weightKg != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(formatKg(weightKg!), style: AppText.display.copyWith(fontSize: 40)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.kg, style: AppText.secondary),
                    ],
                  )
                else
                  Text(
                    l10n.addWeightHint,
                    style: AppText.body.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () => showWeightSheet(context, current: weightKg),
            child: Text(weightKg == null ? l10n.add : l10n.update),
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
    if (weight == null) return l10n.enterNumber;
    if (weight < _min || weight > _max) return l10n.weightRange(_min.toInt(), _max.toInt());
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
                Text(l10n.todaysWeight, style: AppText.heading),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.weightTrendNote, style: AppText.secondary),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  style: AppText.number,
                  validator: _validate,
                  onFieldSubmitted: (_) => _save(),
                  decoration: InputDecoration(labelText: l10n.weight, suffixText: l10n.kg),
                ),
                const SizedBox(height: AppSpacing.xl),
                LoadingButton(label: l10n.save, loading: _saving, onPressed: _save),
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
          ..showSnackBar(SnackBar(content: Text(l10n.bioSaved)));
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
          Text(l10n.bio, style: AppText.secondary),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            maxLength: _maxLength,
            style: AppText.body,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.bioHint,
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
                    child: LoadingButton(label: l10n.saveBio, loading: _saving, onPressed: _save),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- shared bits

// ---------------------------------------------------------------- language

/// Arabic, English, or whatever the phone uses. Changes the whole app right away.
class _LanguageCard extends ConsumerWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.language, style: AppText.secondary),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppLanguage>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: AppLanguage.system, label: Text(l10n.languageSystem)),
                ButtonSegment(value: AppLanguage.arabic, label: Text(l10n.languageArabic)),
                ButtonSegment(value: AppLanguage.english, label: Text(l10n.languageEnglish)),
              ],
              selected: {current},
              onSelectionChanged: (choice) => ref.read(languageProvider.notifier).choose(choice.first),
            ),
          ),
        ],
      ),
    );
  }
}

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
