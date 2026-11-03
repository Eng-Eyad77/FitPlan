import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/loading_button.dart';
import '../application/plans_controller.dart';
import '../domain/workout_plan.dart';

/// Create a plan ([plan] null) or rename it. Returns the created plan, or null.
Future<WorkoutPlan?> showPlanFormSheet(BuildContext context, {WorkoutPlan? plan}) {
  return showModalBottomSheet<WorkoutPlan>(
    context: context,
    // cover the tab bar too
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _PlanFormSheet(plan: plan),
  );
}

class _PlanFormSheet extends ConsumerStatefulWidget {
  const _PlanFormSheet({this.plan});

  final WorkoutPlan? plan;

  @override
  ConsumerState<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends ConsumerState<_PlanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.plan?.name);
  late final _description = TextEditingController(text: widget.plan?.description);
  bool _saving = false;

  bool get _isNew => widget.plan == null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _name.text.trim();
    final description = _description.text.trim().isEmpty ? null : _description.text.trim();
    final controller = ref.read(plansControllerProvider.notifier);

    try {
      if (_isNew) {
        final plan = await controller.create(name: name, description: description);
        if (mounted) Navigator.pop(context, plan);
      } else {
        await controller.rename(widget.plan!.id, name: name, description: description);
        if (mounted) Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // keep the fields above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_isNew ? 'New plan' : 'Edit plan', style: AppText.heading),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _name,
                autofocus: _isNew,
                maxLength: PlanLimits.nameLength,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'Push day', counterText: ''),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Give your plan a name' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _description,
                maxLength: PlanLimits.descriptionLength,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Chest, shoulders and triceps',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LoadingButton(
                label: _isNew ? 'Create plan' : 'Save',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
