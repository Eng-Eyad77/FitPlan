import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The exercise GIF in a rounded box. The GIFs have a white background,
/// so the box is white too and blends with them.
class ExerciseThumb extends StatelessWidget {
  const ExerciseThumb({super.key, required this.url, this.size = 56});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.surface2,
      child: Icon(Icons.fitness_center_rounded, color: AppColors.textTertiary, size: size * 0.4),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(size >= 96 ? AppRadius.md : AppRadius.sm),
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: Colors.white,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            // decode at the shown size, not the full GIF size (saves memory in long lists)
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, _, _) => placeholder,
            // the placeholder until the first frame is decoded (not only downloaded),
            // so a slow GIF never shows as an empty white box
            frameBuilder: (_, child, frame, loadedSync) =>
                frame == null && !loadedSync ? placeholder : child,
          ),
        ),
      ),
    );
  }
}
