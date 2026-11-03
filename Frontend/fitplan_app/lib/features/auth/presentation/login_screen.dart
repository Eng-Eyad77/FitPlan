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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(_username.text, _password.text);
      // the router sends the user to Home on its own
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Log in to continue your training.',
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
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Enter your username' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                label: 'Password',
                onSubmitted: (_) => _submit(),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter your password' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              LoadingButton(label: 'Log in', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('New to FitPlan?', style: AppText.secondary),
          TextButton(
            onPressed: _loading ? null : () => context.go(Routes.register),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
