import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The primary FilledButton, with a spinner while [loading] (and disabled meanwhile).
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: loading
            ? const SizedBox(
                key: ValueKey('spinner'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.onButton),
              )
            : Text(label, key: const ValueKey('label')),
      ),
    );
  }
}
