import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';

/// Round profile picture, or the first letter of the username when there is none.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initial,
    this.imageUrl,
    this.size = 52,
  });

  final String initial;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = Center(
      child: Text(initial, style: AppText.bodyStrong.copyWith(fontSize: size * 0.36)),
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: imageUrl == null
          ? letter
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              // a broken or slow image falls back to the letter instead of an error icon
              errorBuilder: (_, _, _) => letter,
              loadingBuilder: (_, child, progress) => progress == null ? child : letter,
            ),
    );
  }
}
