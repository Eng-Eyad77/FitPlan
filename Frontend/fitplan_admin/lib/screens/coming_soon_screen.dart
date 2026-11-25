import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';

import 'shell.dart';

/// An area that isn't built yet. Says which part of Phase 12 brings it.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.area});

  final AdminArea area;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(area.label, style: AppText.heading),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${area.label} comes in ${area.part}, following the approved design.',
              style: AppText.secondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
