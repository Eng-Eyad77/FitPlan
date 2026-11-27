import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

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
            // on the web the GIF host sends no CORS headers, so the canvas can't read the file;
            // an <img> element can show it anyway. Phones don't need this and ignore it.
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            // decode at the shown size, not the full GIF size (saves memory in long lists)
            // (not on the web: a resized image can't use the <img> fallback below)
            cacheWidth: kIsWeb ? null : (size * MediaQuery.devicePixelRatioOf(context)).round(),
            // some exercises have no demo (the source lost 176 of them), or there's no internet:
            // say so, so it is not mistaken for loading. The instructions still show.
            errorBuilder: (_, _, _) => _NoDemo(size: size),
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
      label: l10n.showHowToDoIt,
      child: GestureDetector(onTap: onTap, child: thumb),
    );
  }
}

/// Shown instead of a demo that can't load. Big: an icon and a line of text. Small: the icon only.
class _NoDemo extends StatelessWidget {
  const _NoDemo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final big = size >= 96;
    return Semantics(
      label: big ? l10n.demoNotAvailableFull : l10n.demoNotAvailable,
      excludeSemantics: true,
      child: ColoredBox(
        color: AppColors.surface2,
        child: Center(
          child: big
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_off_outlined, color: AppColors.textTertiary, size: (size * 0.18).clamp(24, 48)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.demoNotAvailable, style: AppText.bodyStrong, textAlign: TextAlign.center),
                      const SizedBox(height: 2),
                      Text(l10n.followStepsBelow, style: AppText.caption, textAlign: TextAlign.center),
                    ],
                  ),
                )
              : Icon(Icons.videocam_off_outlined, color: AppColors.textTertiary, size: size * 0.4),
        ),
      ),
    );
  }
}
