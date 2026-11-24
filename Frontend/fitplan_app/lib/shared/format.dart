/// Small text formatters shared by all screens.
library;

import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

/// 60.0 -> "60", 62.5 -> "62.5"
String formatKg(double kg) => kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : '$kg';

/// 2140 -> "2,140 kg", 12400 -> "12.4k kg", 0 -> "—" (nothing lifted: bodyweight or cardio only)
String formatVolume(double kg) {
  if (kg.round() == 0) return '—';
  if (kg >= 10000) return l10n.volumeThousandsKg(NumberFormat('0.#').format(kg / 1000));
  return l10n.amountKg(NumberFormat.decimalPattern().format(kg.round()));
}

/// For tight spots where the unit is in the label: 4230 -> "4,230", 12400 -> "12.4k"
String formatVolumeNumber(double kg) => kg >= 10000
    ? l10n.volumeThousands(NumberFormat('0.#').format(kg / 1000))
    : NumberFormat.decimalPattern().format(kg.round());

/// One set, weight first: "65 kg × 8", or "12 reps" without a weight.
String formatSet(double? kg, int reps) => kg == null ? l10n.repsCount(reps) : l10n.setWeightReps(formatKg(kg), reps);

/// 75 -> "1:15", 3725 -> "1:02:05"
String formatClock(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// 2700 -> "45 min", 4500 -> "1 h 15 min", 20 -> "< 1 min"
String formatDuration(int totalSeconds) {
  if (totalSeconds < 30) return l10n.durationUnderMinute;
  final minutes = (totalSeconds / 60).round();
  if (minutes < 60) return l10n.durationMinutes(minutes);
  final rest = minutes % 60;
  return rest == 0 ? l10n.durationHours(minutes ~/ 60) : l10n.durationHoursMinutes(minutes ~/ 60, rest);
}

/// "today", "yesterday", "4 days ago"
String formatDaysAgo(DateTime date, [DateTime? now]) {
  final today = _dateOnly(now ?? DateTime.now());
  final days = today.difference(_dateOnly(date.toLocal())).inDays;
  return switch (days) {
    <= 0 => l10n.today,
    1 => l10n.yesterday,
    _ => l10n.daysAgo(days),
  };
}

/// The API's body part ("upper legs") in the app's language ("Upper legs", "أرجل").
String bodyPartName(String part) => switch (part) {
      'chest' => l10n.bodyChest,
      'back' => l10n.bodyBack,
      'shoulders' => l10n.bodyShoulders,
      'upper arms' => l10n.bodyUpperArms,
      'lower arms' => l10n.bodyLowerArms,
      'upper legs' => l10n.bodyUpperLegs,
      'lower legs' => l10n.bodyLowerLegs,
      'waist' => l10n.bodyWaist,
      'neck' => l10n.bodyNeck,
      'cardio' => l10n.bodyCardio,
      _ => capitalize(part),
    };

/// "upper legs" -> "Upper legs"
String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
