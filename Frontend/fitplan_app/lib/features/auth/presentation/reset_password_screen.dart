import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/loading_button.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';
import 'auth_messages.dart';
import 'widgets/auth_layout.dart';
import 'widgets/email_code.dart';
import '../../../l10n/l10n.dart';

/// A forgotten password (D18): the account's email gets a code, the code is checked, then the new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  /// The address the code went to; null while on step 1.
  String? _sentTo;

  /// The server accepted the code; step 3 asks for the new password.
  bool _codeOk = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
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

  Future<void> _sendCode({bool again = false}) async {
    if (_loading || (!again && !_formKey.currentState!.validate())) return;
    final email = _sentTo ?? _email.text.trim();
    await _run(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetCode(email);
      if (!mounted) return;
      setState(() => _sentTo = email);
      if (again) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.codeResent)));
      }
    });
  }

  Future<void> _checkCode() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    await _run(() async {
      await ref.read(authRepositoryProvider).checkPasswordResetCode(email: _sentTo!, code: _code.text);
      if (mounted) setState(() => _codeOk = true);
    });
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    // signed in on success: the router opens Home
    await _run(() async {
      try {
        await ref
            .read(authControllerProvider.notifier)
            .resetPassword(email: _sentTo!, code: _code.text, newPassword: _password.text);
      } on ApiException catch (error) {
        // the code ran out meanwhile: back to it, with the message
        if (error.code == 'InvalidEmailCode' && mounted) setState(() => _codeOk = false);
        rethrow;
      }
    });
  }

  List<Widget> _emailStep() => [
        EmailField(controller: _email, onSubmitted: (_) => _sendCode()),
        const SizedBox(height: AppSpacing.xl),
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: AppSpacing.lg),
        ],
        LoadingButton(label: l10n.sendCode, loading: _loading, onPressed: _sendCode),
      ];

  List<Widget> _codeStep() => [
        CodeSentNote(
          email: _sentTo!,
          onResend: _loading ? null : () => _sendCode(again: true),
          onChangeEmail: _loading
              ? null
              : () => setState(() {
                    _sentTo = null;
                    _code.clear();
                    _error = null;
                  }),
        ),
        const SizedBox(height: AppSpacing.md),
        EmailCodeField(controller: _code, onSubmitted: (_) => _checkCode()),
        const SizedBox(height: AppSpacing.xl),
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: AppSpacing.lg),
        ],
        LoadingButton(label: l10n.confirm, loading: _loading, onPressed: _checkCode),
      ];

  List<Widget> _passwordStep() => [
        PasswordField(
          controller: _password,
          label: l10n.newPassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          validator: (value) =>
              (value == null || value.length < 8 || value.length > 100) ? l10n.passwordLengthRange : null,
        ),
        const SizedBox(height: AppSpacing.md),
        PasswordField(
          controller: _confirm,
          label: l10n.confirmNewPassword,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: (_) => _submit(),
          validator: (value) => value != _password.text ? l10n.thePasswordsDontMatch : null,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: AppSpacing.lg),
        ],
        LoadingButton(label: l10n.resetPassword, loading: _loading, onPressed: _submit),
      ];

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: l10n.resetTitle,
      subtitle: l10n.resetSubtitle,
      form: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _sentTo == null
                ? _emailStep()
                : _codeOk
                    ? _passwordStep()
                    : _codeStep(),
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.rememberedIt, style: AppText.secondary),
          TextButton(
            onPressed: _loading ? null : () => context.go(Routes.login),
            child: Text(l10n.logIn),
          ),
        ],
      ),
    );
  }
}
