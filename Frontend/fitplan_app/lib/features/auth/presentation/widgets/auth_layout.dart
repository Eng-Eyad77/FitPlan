import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/widgets/brand_mark.dart';

/// Shared frame of the login and register screens.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screen.copyWith(top: 32, bottom: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(alignment: Alignment.centerLeft, child: BrandMark()),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(title, style: AppText.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle, style: AppText.secondary),
                  const SizedBox(height: AppSpacing.xxxl),
                  form,
                  const SizedBox(height: AppSpacing.xxl),
                  footer,
                ]
                    .animate(interval: 40.ms)
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A server error shown above the submit button.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: AppText.secondary.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).shakeX(hz: 4, amount: 3, duration: 300.ms);
  }
}

/// Password field with a show / hide button.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.password],
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String> autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      style: AppText.body,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          tooltip: _hidden ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: Icon(
            _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
