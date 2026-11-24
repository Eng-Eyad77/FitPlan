import 'package:flutter/material.dart';

import '../shared/widgets/brand_mark.dart';

/// Shown for a moment while the saved session is read from secure storage. Same colour and logo
/// size as the native launch screen (iOS LaunchScreen.storyboard, Android launch_background.xml),
/// so the hand-over doesn't flash.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const background = Color(0xFF0E3B3D);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: Center(child: BrandMark(size: 120)),
    );
  }
}
