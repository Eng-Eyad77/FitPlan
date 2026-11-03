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

IconData cardioIcon(CardioMachine machine) => switch (machine) {
      CardioMachine.treadmill => Icons.directions_run_rounded,
      CardioMachine.stationaryBike => Icons.directions_bike_rounded,
      CardioMachine.elliptical => Icons.sync_rounded,
      CardioMachine.stairClimber => Icons.stairs_rounded,
      CardioMachine.rower => Icons.rowing_rounded,
      CardioMachine.other => Icons.favorite_rounded,
    };

/// Machine + minutes. Speed, incline and distance are optional, behind "More details".
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
  final _speed = TextEditingController();
  final _incline = TextEditingController();
  final _distance = TextEditingController();
  bool _showDetails = false;
  bool _saving = false;
  String? _error;

  static const _quickMinutes = [10, 15, 20, 30, 45];

  @override
  void dispose() {
    _minutes.dispose();
    _speed.dispose();
    _incline.dispose();
    _distance.dispose();
    super.dispose();
  }

  double? _decimal(TextEditingController c) {
    final text = c.text.trim().replaceAll(',', '.');
    return text.isEmpty ? null : double.tryParse(text);
  }

  String? _validate() {
    final minutes = int.tryParse(_minutes.text.trim());
    if (minutes == null || minutes < 1 || minutes > 300) return 'Duration: 1 to 300 minutes';
    final speed = _decimal(_speed);
    if (_speed.text.trim().isNotEmpty && (speed == null || speed < 0.1 || speed > 30)) {
      return 'Speed: 0.1 to 30 km/h';
    }
    final incline = _decimal(_incline);
    if (_incline.text.trim().isNotEmpty && (incline == null || incline < 0 || incline > 40)) {
      return 'Incline: 0 to 40%';
    }
    final distance = _decimal(_distance);
    if (_distance.text.trim().isNotEmpty && (distance == null || distance < 0.01 || distance > 100)) {
      return 'Distance: up to 100 km';
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
              speedKmh: _decimal(_speed),
              inclinePercent: _machine.supportsIncline ? _decimal(_incline) : null,
              distanceKm: _decimal(_distance),
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
            const Text('Add cardio', style: AppText.heading),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.35,
              children: [
                for (final machine in CardioMachine.values)
                  _MachineTile(
                    machine: machine,
                    selected: machine == _machine,
                    onTap: () => setState(() => _machine = machine),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('How long?', style: AppText.bodyStrong),
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
                    decoration: const InputDecoration(suffixText: 'min', isDense: true),
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
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
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
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                icon: Icon(_showDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                label: const Text('More details (optional)'),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !_showDetails
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(child: _DecimalField(controller: _speed, label: 'Speed', suffix: 'km/h')),
                          if (_machine.supportsIncline) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: _DecimalField(controller: _incline, label: 'Incline', suffix: '%')),
                          ],
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: _DecimalField(controller: _distance, label: 'Distance', suffix: 'km')),
                        ],
                      ),
                    ),
            ),
            if (!hasWeight) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add your weight in Profile to see the calories you burn.',
                style: AppText.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: AppText.caption.copyWith(color: AppColors.danger)),
            ],
            const SizedBox(height: AppSpacing.xl),
            LoadingButton(label: 'Add cardio', loading: _saving, onPressed: _save),
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

class _DecimalField extends StatelessWidget {
  const _DecimalField({required this.controller, required this.label, required this.suffix});

  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(5),
      ],
      decoration: InputDecoration(labelText: label, suffixText: suffix, isDense: true),
    );
  }
}
