import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/format.dart';
import '../../domain/workout_session.dart';
import 'set_rows.dart';

sealed class SetEdit {
  const SetEdit();
}

class SetChanged extends SetEdit {
  const SetChanged(this.reps, this.weightKg);
  final int reps;
  final double? weightKg;
}

class SetDeleted extends SetEdit {
  const SetDeleted();
}

/// Fix a logged set, or delete it. Returns null when dismissed.
Future<SetEdit?> showSetEditSheet(BuildContext context, SessionSet set) {
  return showModalBottomSheet<SetEdit>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _SetEditSheet(set: set),
  );
}

class _SetEditSheet extends StatefulWidget {
  const _SetEditSheet({required this.set});

  final SessionSet set;

  @override
  State<_SetEditSheet> createState() => _SetEditSheetState();
}

class _SetEditSheetState extends State<_SetEditSheet> {
  late final _kg = TextEditingController(
    text: widget.set.weightKg == null ? '' : formatKg(widget.set.weightKg!),
  );
  late final _reps = TextEditingController(text: '${widget.set.reps}');
  String? _error;

  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _save() {
    final reps = int.tryParse(_reps.text.trim());
    final kgText = _kg.text.trim().replaceAll(',', '.');
    final kg = kgText.isEmpty ? null : double.tryParse(kgText);

    final error = validateSet(reps: reps, kgText: kgText, kg: kg);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, SetChanged(reps!, kg));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set ${widget.set.setNumber}', style: AppText.heading),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _kg,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        helperText: 'Empty = bodyweight',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _reps,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Reps', helperText: ' '),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: AppText.caption.copyWith(color: AppColors.danger)),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: _save, child: const Text('Save')),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context, const SetDeleted()),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Delete set'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
