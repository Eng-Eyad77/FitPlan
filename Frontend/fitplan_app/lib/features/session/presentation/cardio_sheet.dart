import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../profile/application/profile_controller.dart';
import '../application/active_session_controller.dart';
import '../data/sessions_repository.dart';
import '../domain/workout_session.dart';
import '../../../l10n/l10n.dart';

IconData cardioIcon(CardioMachine machine) => switch (machine) {
      CardioMachine.treadmill => Icons.directions_run_rounded,
      CardioMachine.stationaryBike => Icons.directions_bike_rounded,
      CardioMachine.elliptical => Icons.sync_rounded,
      CardioMachine.stairClimber => Icons.stairs_rounded,
      CardioMachine.rower => Icons.rowing_rounded,
      CardioMachine.swimming => Icons.pool_rounded,
      CardioMachine.other || CardioMachine.unknown => Icons.favorite_rounded,
    };

/// Machine + minutes. The machine's own details (what its display shows) are optional, behind "More details".
Future<void> showCardioSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CardioSheet(),
  );
}

class _CardioSheet extends ConsumerStatefulWidget {
  const _CardioSheet();

  @override
  ConsumerState<_CardioSheet> createState() => _CardioSheetState();
}

class _CardioSheetState extends ConsumerState<_CardioSheet> {
  CardioMachine _machine = CardioMachine.treadmill;
  final _minutes = TextEditingController(text: '15');

  /// One per detail, kept while switching machines; only the chosen machine's are sent.
  final _fields = {for (final f in CardioField.values) f: TextEditingController()};
  bool _showDetails = false;
  bool _saving = false;
  String? _error;

  static const _quickMinutes = [10, 15, 20, 30, 45];

  @override
  void dispose() {
    _minutes.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// The typed value of [field], null when empty. Throws FormatException when it doesn't parse.
  num? _value(CardioField field) {
    final text = _fields[field]!.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final value = field.decimal ? double.tryParse(text) : int.tryParse(text);
    if (value == null) throw const FormatException();
    return value;
  }

  String? _validate() {
    final minutes = int.tryParse(_minutes.text.trim());
    if (minutes == null || minutes < 1 || minutes > 300) return l10n.durationRange;
    for (final field in _machine.fields) {
      try {
        final value = _value(field);
        if (value != null && (value < field.min || value > field.max)) return field.rangeText;
      } on FormatException {
        return field.rangeText;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(activeSessionControllerProvider.notifier).addCardio(
            CardioInput(
              machine: _machine,
              durationSeconds: int.parse(_minutes.text.trim()) * 60,
              values: {
                for (final field in _machine.fields)
                  field: ?_value(field),
              },
            ),
          );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWeight = ref.watch(profileControllerProvider).value?.currentWeightKg != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.addCardio, style: AppText.heading),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.35,
              children: [
                for (final machine in CardioMachine.choices)
                  _MachineTile(
                    machine: machine,
                    selected: machine == _machine,
                    onTap: () => setState(() {
                      _machine = machine;
                      _error = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.howLong, style: AppText.bodyStrong),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    textAlign: TextAlign.center,
                    style: AppText.number.copyWith(fontSize: 22),
                    decoration: InputDecoration(suffixText: l10n.minUnit, isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final m in _quickMinutes)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                            child: ChoiceChip(
                              label: Text('$m'),
                              selected: _minutes.text == '$m',
                              showCheckmark: false,
                              onSelected: (_) => setState(() => _minutes.text = '$m'),
                              selectedColor: AppColors.accent,
                              labelStyle: AppText.secondary.copyWith(
                                color: _minutes.text == '$m' ? AppColors.onAccent : AppColors.textSecondary,
                              ),
                              backgroundColor: AppColors.surface2,
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                icon: Icon(_showDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                label: Text(l10n.moreDetails),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !_showDetails
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              for (final (i, field) in _machine.fields.indexed) ...[
                                if (i > 0) const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _NumberField(
                                    key: ValueKey(field),
                                    controller: _fields[field]!,
                                    field: field,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_machine == CardioMachine.swimming) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.swimDistanceNote,
                              style: AppText.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasWeight
                  ? (_machine == CardioMachine.treadmill ? l10n.caloriesRough : l10n.caloriesRoughMachine)
                  : l10n.addWeightForCalories,
              style: AppText.caption.copyWith(color: AppColors.textSecondary),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: AppText.caption.copyWith(color: AppColors.danger)),
            ],
            const SizedBox(height: AppSpacing.xl),
            LoadingButton(label: l10n.addCardio, loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  const _MachineTile({required this.machine, required this.selected, required this.onTap});

  final CardioMachine machine;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.accentTint(0.14) : AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: selected ? AppColors.accent : Colors.transparent, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cardioIcon(machine), color: selected ? AppColors.accent : AppColors.textSecondary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                machine.label,
                style: AppText.caption.copyWith(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({super.key, required this.controller, required this.field});

  final TextEditingController controller;
  final CardioField field;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: field.decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(field.decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]')),
        LengthLimitingTextInputFormatter(field.decimal ? 5 : 5),
      ],
      decoration: InputDecoration(
        labelText: field.label,
        suffixText: field.unit.isEmpty ? null : field.unit,
        isDense: true,
      ),
    );
  }
}
