import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/format.dart';
import '../../domain/workout_session.dart';
import '../../../../l10n/l10n.dart';

/// Same limits as the API, checked before sending. Null when valid.
String? validateSet({required int? reps, required String kgText, required double? kg}) {
  if (reps == null || reps < 1 || reps > SessionLimits.maxReps) {
    return l10n.repsRange(SessionLimits.maxReps);
  }
  if (kgText.isNotEmpty && (kg == null || kg < 0 || kg > SessionLimits.maxWeightKg)) {
    return l10n.weightRangeSet(formatKg(SessionLimits.maxWeightKg));
  }
  return null;
}

/// Column widths shared by the header and every row, so they line up.
abstract final class SetColumns {
  static const set = 40.0;
  static const done = 52.0;
}

class SetTableHeader extends StatelessWidget {
  const SetTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = AppText.caption.copyWith(letterSpacing: 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: SetColumns.set, child: Text(l10n.colSet, style: style)),
          Expanded(child: Text(l10n.colKg, style: style, textAlign: TextAlign.center)),
          Expanded(child: Text(l10n.colReps, style: style, textAlign: TextAlign.center)),
          const SizedBox(width: SetColumns.done),
        ],
      ),
    );
  }
}

/// A set already saved. Tap to edit or delete it.
/// Shows the progress against last time ("+2.5 kg") under the value, never on top of it.
class LoggedSetRow extends StatelessWidget {
  const LoggedSetRow({super.key, required this.set, this.previous, required this.onTap});

  final SessionSet set;

  /// The same set number last time, to compare with.
  final SessionSet? previous;
  final VoidCallback onTap;

  /// Heavier than last time: "+2.5 kg" under the weight.
  String? get _kgGain {
    final before = previous;
    if (before == null) return null;
    final kgDiff = (set.weightKg ?? 0) - (before.weightKg ?? 0);
    return kgDiff > 0 ? l10n.amountKg(signed('+${formatKg(kgDiff)}')) : null;
  }

  /// Same weight, more reps: "+2 reps" under the reps.
  String? get _repsGain {
    final before = previous;
    if (before == null || (set.weightKg ?? 0) != (before.weightKg ?? 0)) return null;
    return set.reps > before.reps ? signed('+${set.reps - before.reps}') : null;
  }

  Widget _value(String value, String? gain) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppText.number.copyWith(fontSize: 20)),
          if (gain != null)
            Text(gain, style: AppText.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.setDoneSemantics(
        set.setNumber,
        set.weightKg == null ? l10n.semBodyweight : l10n.semKilograms(formatKg(set.weightKg!)),
        set.reps,
      ),
      excludeSemantics: true,
      child: Material(
        color: AppColors.accentTint(0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouch + 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: SetColumns.set,
                    child: Text('${set.setNumber}', style: AppText.bodyStrong.copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: _value(set.weightKg == null ? l10n.bodyweightShort : formatKg(set.weightKg!), _kgGain)),
                  Expanded(child: _value('${set.reps}', _repsGain)),
                  const SizedBox(
                    width: SetColumns.done,
                    child: Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A set to do: kg and reps already filled in (from this workout or last time),
/// so most of the time the user only taps ✓.
class DraftSetRow extends StatefulWidget {
  const DraftSetRow({
    super.key,
    required this.setNumber,
    required this.onDone,
    this.initialKg,
    this.initialReps,
    this.typed,
    this.onTyped,
    this.highlighted = false,
  });

  final int setNumber;
  final double? initialKg;
  final int? initialReps;

  /// What the user typed before (the card was closed in between). Wins over the pre-fill.
  final ({String kg, String reps})? typed;

  /// Called on every edit by the user, so the values outlive this row.
  final void Function(String kg, String reps)? onTyped;

  /// The next set to do gets the accent border.
  final bool highlighted;

  /// Saves the set. Returns false when it failed (the caller already showed why).
  final Future<bool> Function(int reps, double? weightKg) onDone;

  @override
  State<DraftSetRow> createState() => _DraftSetRowState();
}

class _DraftSetRowState extends State<DraftSetRow> {
  late final _kg = TextEditingController(
    text: widget.typed?.kg ?? (widget.initialKg == null ? '' : formatKg(widget.initialKg!)),
  );
  late final _reps = TextEditingController(text: widget.typed?.reps ?? widget.initialReps?.toString() ?? '');

  void _typed(String _) => widget.onTyped?.call(_kg.text, _reps.text);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    final reps = int.tryParse(_reps.text.trim());
    final kgText = _kg.text.trim().replaceAll(',', '.');
    final kg = kgText.isEmpty ? null : double.tryParse(kgText);

    final error = validateSet(reps: reps, kgText: kgText, kg: kg);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final saved = await widget.onDone(reps!, kg);
    if (saved) HapticFeedback.mediumImpact();
    // on success this row is replaced by a logged row; on failure the user can retry
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: widget.highlighted ? AppColors.accent.withValues(alpha: 0.6) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: SetColumns.set,
                child: Text('${widget.setNumber}', style: AppText.bodyStrong.copyWith(color: AppColors.textSecondary)),
              ),
              Expanded(
                child: _CellField(
                  controller: _kg,
                  hint: l10n.weightHint,
                  label: l10n.setWeightSemantics(widget.setNumber),
                  decimal: true,
                  onChanged: _typed,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CellField(
                  controller: _reps,
                  hint: '0',
                  label: l10n.setRepsSemantics(widget.setNumber),
                  onChanged: _typed,
                  onSubmitted: _done,
                ),
              ),
              SizedBox(
                width: SetColumns.done,
                child: _saving
                    ? const Center(
                        child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.4)),
                      )
                    : IconButton(
                        tooltip: l10n.logSetNumber(widget.setNumber),
                        onPressed: _done,
                        iconSize: 30,
                        color: widget.highlighted ? AppColors.accent : AppColors.textTertiary,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                      ),
              ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm, top: AppSpacing.xs),
            child: Text(_error!, style: AppText.caption.copyWith(color: AppColors.danger)),
          ),
      ],
    );
  }
}

class _CellField extends StatelessWidget {
  const _CellField({
    required this.controller,
    required this.hint,
    required this.label,
    this.decimal = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final String label;
  final bool decimal;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: AppText.number.copyWith(fontSize: 20),
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]')),
          LengthLimitingTextInputFormatter(decimal ? 6 : 3),
        ],
        onChanged: onChanged,
        textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
        onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
        onTap: () => controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: AppText.number.copyWith(fontSize: 20, color: AppColors.textTertiary),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          fillColor: AppColors.background,
        ),
      ),
    );
  }
}
