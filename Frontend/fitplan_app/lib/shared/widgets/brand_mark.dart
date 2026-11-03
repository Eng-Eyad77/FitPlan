import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The FitPlan mark: a dumbbell on the signature gradient.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FitPlan',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.signatureGradient,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.onAccent,
          size: size * 0.5,
        ),
      ),
    );
  }
}
