import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/widgets/number_stepper.dart';
import '../../domain/workout_session.dart';

/// The rest after each set of one exercise, for this workout only. Returns null when dismissed.
Future<int?> showRestSheet(BuildContext context, {required String title, required int seconds}) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (_) => _RestSheet(title: title, seconds: seconds),
  );
}

class _RestSheet extends StatefulWidget {
  const _RestSheet({required this.title, required this.seconds});

  final String title;
  final int seconds;

  @override
  State<_RestSheet> createState() => _RestSheetState();
}

class _RestSheetState extends State<_RestSheet> {
  late int _seconds = widget.seconds.clamp(RestLimits.min, RestLimits.max);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppText.heading, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.xs),
            const Text('Rest after each set, for this workout. Your plan stays as it is.', style: AppText.secondary),
            const SizedBox(height: AppSpacing.lg),
            NumberStepper(
              label: 'Rest between sets',
              value: _seconds,
              min: RestLimits.min,
              max: RestLimits.max,
              step: RestLimits.step,
              format: formatRest,
              onChanged: (v) => setState(() => _seconds = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: () => Navigator.pop(context, _seconds), child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
