/// Small text formatters shared by all screens.
library;

/// 60.0 -> "60", 62.5 -> "62.5"
String formatKg(double kg) => kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : '$kg';

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
