import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/admin_api.dart';
import 'shell.dart';

/// Two steps on screen, one request: the server checks the password and the code together,
/// so a wrong password is never told apart from a wrong code.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _askCode = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _askCode = true;
      _error = null;
    });
  }

  Future<void> _signIn() async {
    if (_code.text.length != 6) {
      setState(() => _error = 'Enter the 6 digits from your authenticator app.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.signIn(login: _login.text.trim(), password: _password.text, code: _code.text);
    } on AdminApiException catch (e) {
      _code.clear();
      if (mounted) setState(() => _error = e.code == 'InvalidAdminSignIn' ? '${e.message} Check both and try again.' : e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.4, -0.6),
            radius: 0.8,
            // opaque on purpose: a see-through teal blends into a bright ring
            colors: [Color(0xFF14262A), AppColors.background],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(child: BrandMark(size: 48)),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AutofillGroup(child: _askCode ? _codeStep() : _passwordStep()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Step ${_askCode ? 2 : 1} of 2', style: AppText.caption),
                      const SizedBox(width: AppSpacing.md),
                      const EnvChip(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordStep() {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Admin sign in', style: AppText.heading),
          const SizedBox(height: AppSpacing.xs),
          const Text("Use your FitPlan admin account. Normal app accounts can't sign in here.", style: AppText.secondary),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _login,
            autofocus: true,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(labelText: 'Email or username'),
            textInputAction: TextInputAction.next,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter your email or username.' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Password'),
            onFieldSubmitted: (_) => _continue(),
            validator: (v) => v == null || v.isEmpty ? 'Enter your password.' : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _continue, child: const Text('Continue')),
        ],
      ),
    );
  }

  Widget _codeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Enter your code', style: AppText.heading),
        const SizedBox(height: AppSpacing.xs),
        const Text('Open your authenticator app and type the 6-digit code for FitPlan Admin.', style: AppText.secondary),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _code,
          autofocus: true,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          textAlign: TextAlign.center,
          style: AppText.number.copyWith(letterSpacing: 10),
          decoration: const InputDecoration(hintText: '000000'),
          onSubmitted: (_) => _signIn(),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: AppText.secondary.copyWith(color: AppColors.danger)),
        ],
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _busy ? null : _signIn,
          child: _busy
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onButton))
              : const Text('Sign in'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _busy ? null : () => setState(() {
                    _askCode = false;
                    _error = null;
                  }),
          child: const Text('Back to email and password'),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('Lost your phone? Run make-owner again to get a new secret. The old codes stop working.',
            style: AppText.caption),
      ],
    );
  }
}
