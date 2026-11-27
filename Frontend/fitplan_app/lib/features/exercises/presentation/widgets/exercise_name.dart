import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';

import '../../../../shared/format.dart';

/// An exercise's name, with the English name small under it when the name is in Arabic
/// (Phase 11C): gyms say most of these names in English, so both stay recognisable.
class ExerciseName extends StatelessWidget {
  const ExerciseName({
    super.key,
    required this.name,
    this.englishName,
    this.style = AppText.bodyStrong,
    this.maxLines = 2,
  });

  final String name;
  final String? englishName;
  final TextStyle style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final english = englishName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(capitalize(name), style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis),
        if (english != null && english != name)
          Text(
            capitalize(english),
            style: AppText.caption.copyWith(color: AppColors.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }
}
