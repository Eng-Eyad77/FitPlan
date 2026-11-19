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

/// A forgotten password: the username, the recovery code saved at sign-up, and a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _code.dispose();
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
      await ref.read(authControllerProvider.notifier).resetPassword(_username.text, _code.text, _password.text);
      // signed in: the router opens Home, and the new recovery code shows over it
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Reset your password',
      subtitle: 'Use the recovery code you saved when you created your account.',
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _username,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                style: AppText.body,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter your username' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _code,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                style: AppText.body,
                decoration: const InputDecoration(labelText: 'Recovery code', hintText: 'XXXX-XXXX-XXXX-XXXX'),
                validator: (value) {
                  final letters = (value ?? '').replaceAll(RegExp('[^A-Za-z0-9]'), '');
                  return letters.length == 16 ? null : 'The code has 16 letters and numbers';
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                label: 'New password',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) =>
                    (value == null || value.length < 8 || value.length > 100) ? 'Use 8 to 100 characters' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _confirm,
                label: 'Confirm new password',
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                validator: (value) => value != _password.text ? "The passwords don't match" : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              LoadingButton(label: 'Reset password', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Remembered it?', style: AppText.secondary),
          TextButton(
            onPressed: _loading ? null : () => context.go(Routes.login),
            child: const Text('Log in'),
          ),
        ],
      ),
    );
  }
}
