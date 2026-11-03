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
    if (username.length < _minUsername) return 'At least $_minUsername characters';
    if (username.length > _maxUsername) return 'At most $_maxUsername characters';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < _minPassword) return 'At least $_minPassword characters';
    if (password.length > _maxPassword) return 'At most $_maxPassword characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create your account',
      subtitle: 'Plan your workouts, log every set, and watch yourself get stronger.',
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
                decoration: const InputDecoration(labelText: 'Username', counterText: ''),
                validator: _validateUsername,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                label: 'Password',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validatePassword,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _confirm,
                label: 'Confirm password',
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                validator: (value) => value != _password.text ? "Passwords don't match" : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Use at least $_minPassword characters.', style: AppText.caption),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              LoadingButton(label: 'Create account', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account?', style: AppText.secondary),
          TextButton(
            onPressed: _loading ? null : () => context.go(Routes.login),
            child: const Text('Log in'),
          ),
        ],
      ),
    );
  }
}
