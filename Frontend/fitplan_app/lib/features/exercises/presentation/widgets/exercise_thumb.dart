import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The exercise GIF in a rounded box. The GIFs have a white background,
/// so the box is white too and blends with them.
class ExerciseThumb extends StatelessWidget {
  const ExerciseThumb({super.key, required this.url, this.size = 56, this.onTap});

  final String url;
  final double size;

  /// Usually opens the exercise details.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) => ColoredBox(
          color: AppColors.surface2,
          child: Icon(icon, color: AppColors.textTertiary, size: size * 0.4),
        );

    final thumb = ClipRRect(
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
            // a different icon when it failed (no internet), so it is not mistaken for loading
            errorBuilder: (_, _, _) => placeholder(Icons.image_not_supported_outlined),
            // the placeholder until the first frame is decoded (not only downloaded),
            // so a slow GIF never shows as an empty white box
            frameBuilder: (_, child, frame, loadedSync) =>
                frame == null && !loadedSync ? placeholder(Icons.fitness_center_rounded) : child,
          ),
        ),
      ),
    );

    if (onTap == null) return thumb;
    return Semantics(
      button: true,
      label: 'Show how to do it',
      child: GestureDetector(onTap: onTap, child: thumb),
    );
  }
}
