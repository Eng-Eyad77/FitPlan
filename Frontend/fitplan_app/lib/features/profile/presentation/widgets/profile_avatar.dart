import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/profile_controller.dart';

/// Round profile picture, or the first letter of the username when there is none.
/// [pictureUrl] is the profile's ProfilePictureUrl: it identifies the picture, which is loaded
/// through the API with the session, because only its owner may see it.
class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({
    super.key,
    required this.initial,
    this.pictureUrl,
    this.size = 52,
  });

  final String initial;
  final String? pictureUrl;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letter = Center(
      child: Text(initial, style: AppText.bodyStrong.copyWith(fontSize: size * 0.36)),
    );
    // a missing, slow or broken picture shows the letter instead of an error icon
    final bytes = pictureUrl == null ? null : ref.watch(profilePictureProvider(pictureUrl!)).value;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: bytes == null
          ? letter
          : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true, errorBuilder: (_, _, _) => letter),
    );
  }
}
