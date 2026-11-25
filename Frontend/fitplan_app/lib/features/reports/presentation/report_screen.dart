import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/loading_button.dart';
import '../data/report_repository.dart';

/// "Report a problem" (D14) or "Share a suggestion", opened from Profile. On failure the text stays,
/// so nothing typed is lost.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, this.suggestion = false});

  final bool suggestion;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  // same rule as the API (CreateProblemReportDto)
  static const _min = 10;
  static const _max = 2000;

  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ref.read(reportRepositoryProvider).send(_message.text, suggestion: widget.suggestion);
      if (!mounted) return;
      showMessage(context, widget.suggestion ? l10n.suggestSent : l10n.reportSent);
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) {
        showMessage(context, error.code == 'TooManyRequests' ? l10n.reportTooMany : error.message);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    return Scaffold(
      appBar: AppBar(title: Text(suggestion ? l10n.suggestIdea : l10n.reportProblem, style: AppText.heading)),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
          children: [
            Text(suggestion ? l10n.suggestIntro : l10n.reportIntro, style: AppText.secondary),
            const SizedBox(height: AppSpacing.xl),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _message,
                autofocus: true,
                minLines: 6,
                maxLines: 12,
                maxLength: _max,
                textCapitalization: TextCapitalization.sentences,
                style: AppText.body,
                decoration: InputDecoration(hintText: suggestion ? l10n.suggestHint : l10n.reportHint, alignLabelWithHint: true),
                validator: (value) => (value?.trim().length ?? 0) < _min ? l10n.atLeastChars(_min) : null,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(label: l10n.send, loading: _sending, onPressed: _send),
          ],
        ),
      ),
    );
  }
}
