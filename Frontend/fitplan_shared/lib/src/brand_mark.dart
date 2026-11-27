import 'package:flutter/material.dart';

/// The FitPlan logo, the same image as the app icon on the home screen.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  static const asset = 'lib/brand/logo.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FitPlan',
      image: true,
      child: ClipRRect(
        // the icon has its own rounded frame; this only trims the corners outside it
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(asset, package: 'fitplan_shared', width: size, height: size, filterQuality: FilterQuality.medium),
      ),
    );
  }
}
