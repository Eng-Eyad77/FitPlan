import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/loading_button.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';
import 'auth_messages.dart';
import 'widgets/auth_layout.dart';
import 'widgets/email_code.dart';
import '../../../l10n/l10n.dart';

/// Sign-up (D18): email, username and password first, then the code sent to the email.
/// Only the email goes to the server before the code; the account is made with the code,
/// so no unverified account is ever stored.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  /// The address the latest code went to. Going back to fix the username keeps it, so the same
  /// code still works and no new email is needed.
  String? _sentTo;
  bool _onCodeStep = false;
  bool _loading = false;
  String? _error;

  // same rules as the backend (RegisterRequestDto), checked here first for instant feedback
  static const _minUsername = 3;
  static const _maxUsername = 50;
  static const _minPassword = 8;
  static const _maxPassword = 100;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Step 1 -> step 2. A code already sent to the same address is reused.
  Future<void> _continue() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    await _run(() async {
      if (email != _sentTo) {
        await ref.read(authRepositoryProvider).sendSignUpCode(email);
        _code.clear();
      }
      if (mounted) {
        setState(() {
          _sentTo = email;
          _onCodeStep = true;
        });
      }
    });
  }

  Future<void> _resend() => _run(() async {
        await ref.read(authRepositoryProvider).sendSignUpCode(_sentTo!);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.codeResent)));
      });

  void _back() => setState(() {
        _onCodeStep = false;
        _error = null;
      });

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    await _run(() async {
      try {
        await ref.read(authControllerProvider.notifier).register(
              email: _sentTo!,
              code: _code.text,
              username: _username.text,
              password: _password.text,
            );
      } on ApiException catch (error) {
        // the name is fixed on step 1; the code isn't used up, so it still works after
        if (error.code == ApiException.usernameAlreadyExists) _back();
        rethrow;
      }
    });
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.length < _minUsername) return l10n.atLeastChars(_minUsername);
    if (username.length > _maxUsername) return l10n.atMostChars(_maxUsername);
    if (username.contains('@')) return l10n.usernameNoAt;
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < _minPassword) return l10n.atLeastChars(_minPassword);
    if (password.length > _maxPassword) return l10n.atMostChars(_maxPassword);
    return null;
  }

  List<Widget> _detailsStep() => [
        EmailField(controller: _email, newEmail: true, live: true),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _username,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newUsername],
          autocorrect: false,
          maxLength: _maxUsername,
          style: AppText.body,
          decoration: InputDecoration(labelText: l10n.username, counterText: ''),
          validator: _validateUsername,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: AppSpacing.md),
        PasswordField(
          controller: _password,
          label: l10n.password,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          validator: _validatePassword,
          live: true,
        ),
        const SizedBox(height: AppSpacing.md),
        PasswordField(
          controller: _confirm,
          label: l10n.confirmPassword,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: (_) => _continue(),
          validator: (value) => value != _password.text ? l10n.passwordsDontMatch : null,
          live: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        // turns green once the password is long enough
        ListenableBuilder(
          listenable: _password,
          builder: (context, _) {
            final ok = _password.text.length >= _minPassword && _password.text.length <= _maxPassword;
            final color = ok ? AppColors.accent : AppColors.textTertiary;
            return Row(
              children: [
                Icon(ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(l10n.passwordHint(_minPassword), style: AppText.caption.copyWith(color: color))),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: AppSpacing.lg),
        ],
        LoadingButton(label: l10n.createAccount, loading: _loading, onPressed: _continue),
      ];

  List<Widget> _codeStep() => [
        CodeSentNote(
          email: _sentTo!,
          onResend: _loading ? null : _resend,
          onChangeEmail: _loading ? null : _back,
        ),
        const SizedBox(height: AppSpacing.md),
        EmailCodeField(controller: _code, onSubmitted: (_) => _submit()),
        const SizedBox(height: AppSpacing.xl),
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: AppSpacing.lg),
        ],
        LoadingButton(label: l10n.confirm, loading: _loading, onPressed: _submit),
      ];

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _onCodeStep ? _codeStep() : _detailsStep(),
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.haveAccount, style: AppText.secondary),
          TextButton(
            onPressed: _loading ? null : () => context.go(Routes.login),
            child: Text(l10n.logIn),
          ),
        ],
      ),
    );
  }
}
