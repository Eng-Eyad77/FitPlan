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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
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
      await ref.read(authControllerProvider.notifier).login(_login.text, _password.text);
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
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _login,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                autocorrect: false,
                style: AppText.body,
                decoration: InputDecoration(labelText: l10n.emailOrUsername),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.enterEmailOrUsername : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                label: l10n.password,
                onSubmitted: (_) => _submit(),
                validator: (value) =>
                    (value == null || value.isEmpty) ? l10n.enterPassword : null,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _loading ? null : () => context.go(Routes.resetPassword),
                  child: Text(l10n.forgotPassword),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              LoadingButton(label: l10n.logIn, loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.newToFitPlan, style: AppText.secondary),
          TextButton(
            onPressed: _loading ? null : () => context.go(Routes.register),
            child: Text(l10n.createAnAccount),
          ),
        ],
      ),
    );
  }
}
