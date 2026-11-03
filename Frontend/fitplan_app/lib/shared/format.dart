/// Small text formatters shared by all screens.
library;

import 'package:intl/intl.dart';

/// 60.0 -> "60", 62.5 -> "62.5"
String formatKg(double kg) => kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : '$kg';

/// 2140 -> "2,140 kg", 12400 -> "12.4k kg", 0 -> "—" (nothing lifted: bodyweight or cardio only)
String formatVolume(double kg) {
  if (kg.round() == 0) return '—';
  if (kg >= 10000) return '${NumberFormat('0.#').format(kg / 1000)}k kg';
  return '${NumberFormat.decimalPattern().format(kg.round())} kg';
}

/// For tight spots where the unit is in the label: 4230 -> "4,230", 12400 -> "12.4k"
String formatVolumeNumber(double kg) => kg >= 10000
    ? '${NumberFormat('0.#').format(kg / 1000)}k'
    : NumberFormat.decimalPattern().format(kg.round());

/// One set, weight first: "65 kg × 8", or "12 reps" without a weight.
String formatSet(double? kg, int reps) => kg == null ? '$reps reps' : '${formatKg(kg)} kg × $reps';

/// 75 -> "1:15", 3725 -> "1:02:05"
String formatClock(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// 2700 -> "45 min", 4500 -> "1 h 15 min", 20 -> "< 1 min"
String formatDuration(int totalSeconds) {
  if (totalSeconds < 30) return '< 1 min';
  final minutes = (totalSeconds / 60).round();
  if (minutes < 60) return '$minutes min';
  final rest = minutes % 60;
  return rest == 0 ? '${minutes ~/ 60} h' : '${minutes ~/ 60} h $rest min';
}

/// "today", "yesterday", "4 days ago"
String formatDaysAgo(DateTime date, [DateTime? now]) {
  final today = _dateOnly(now ?? DateTime.now());
  final days = today.difference(_dateOnly(date.toLocal())).inDays;
  return switch (days) {
    <= 0 => 'today',
    1 => 'yesterday',
    _ => '$days days ago',
  };
}

/// "upper legs" -> "Upper legs"
String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
