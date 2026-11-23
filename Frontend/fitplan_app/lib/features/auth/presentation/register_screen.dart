import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/loading_button.dart';
import '../application/auth_controller.dart';
import 'auth_messages.dart';
import 'widgets/auth_layout.dart';
import '../../../l10n/l10n.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  String? _error;

  // same rules as the backend (RegisterRequestDto), checked here first for instant feedback
  static const _minUsername = 3;
  static const _maxUsername = 50;
  static const _minPassword = 8;
  static const _maxPassword = 100;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(_username.text, _password.text);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.length < _minUsername) return l10n.atLeastChars(_minUsername);
    if (username.length > _maxUsername) return l10n.atMostChars(_maxUsername);
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < _minPassword) return l10n.atLeastChars(_minPassword);
    if (password.length > _maxPassword) return l10n.atMostChars(_maxPassword);
    return null;
  }

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
            children: [
              TextFormField(
                controller: _username,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                autocorrect: false,
                maxLength: _maxUsername,
                style: AppText.body,
                decoration: InputDecoration(labelText: l10n.username, counterText: ''),
                validator: _validateUsername,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                label: l10n.password,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validatePassword,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _confirm,
                label: l10n.confirmPassword,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                validator: (value) => value != _password.text ? l10n.passwordsDontMatch : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.passwordHint(_minPassword), style: AppText.caption),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              LoadingButton(label: l10n.createAccount, loading: _loading, onPressed: _submit),
            ],
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
