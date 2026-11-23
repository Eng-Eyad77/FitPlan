import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../application/recovery_code.dart';
import '../../../l10n/l10n.dart';

/// Covers the app until the user confirms they saved their recovery code. It is the only way back
/// into the account if the password is forgotten, and the server can't show it again.
class RecoveryCodeNotice extends ConsumerWidget {
  const RecoveryCodeNotice({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(recoveryCodeToShowProvider);

    return Stack(
      children: [
        child,
        if (code != null)
          Positioned.fill(
            child: Material(
              color: AppColors.background,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screen,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.key_rounded, size: 40, color: AppColors.accent),
                          const SizedBox(height: AppSpacing.lg),
                          Text(l10n.recoverySaveTitle, style: AppText.title, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.recoverySaveBody,
                            style: AppText.secondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: SelectableText(
                              code,
                              key: const Key('recovery-code'),
                              textAlign: TextAlign.center,
                              style: AppText.title.copyWith(fontFamily: 'monospace', letterSpacing: 2),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: code));
                              if (context.mounted) {
                                ScaffoldMessenger.maybeOf(context)
                                  ?..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(content: Text(l10n.recoveryCopied)));
                              }
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: Text(l10n.copyCode),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FilledButton(
                            onPressed: () => ref.read(recoveryCodeToShowProvider.notifier).saved(),
                            child: Text(l10n.savedIt),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
