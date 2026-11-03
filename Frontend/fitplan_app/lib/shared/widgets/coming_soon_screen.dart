import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';

/// Placeholder for tabs that are built in the next steps.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(top: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.title),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.construction_rounded, color: AppColors.textTertiary, size: 40),
                    const SizedBox(height: AppSpacing.md),
                    Text('Coming in the next step', style: AppText.secondary),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
