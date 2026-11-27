import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';

/// EN | AR on Home and the sign-in screens: one tap switches the whole app to the other language.
/// Profile still has the full choice, including following the phone.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final arabic = isArabic;

    Widget side(String text, bool active) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            text,
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: active ? AppColors.onAccent : AppColors.textSecondary,
            ),
          ),
        );

    return Semantics(
      button: true,
      label: l10n.switchLanguage,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => ref.read(languageProvider.notifier).choose(arabic ? AppLanguage.english : AppLanguage.arabic),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          // always EN on the left, AR on the right, in both languages
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(mainAxisSize: MainAxisSize.min, children: [side('EN', !arabic), side('AR', arabic)]),
          ),
        ),
      ),
    );
  }
}
