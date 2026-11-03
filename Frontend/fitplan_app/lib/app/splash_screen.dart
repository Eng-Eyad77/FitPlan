import 'package:flutter/material.dart';

import '../shared/widgets/brand_mark.dart';

/// Shown for a moment while the saved session is read from secure storage.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: BrandMark(size: 72)),
    );
  }
}
