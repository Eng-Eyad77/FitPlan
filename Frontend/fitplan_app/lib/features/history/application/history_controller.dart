import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../progress/application/progress_providers.dart';
import '../../session/data/sessions_repository.dart';
import '../../session/domain/workout_session.dart';

/// The loaded part of the history: page after page as the user scrolls.
class HistoryState {
  const HistoryState({required this.items, required this.page, required this.hasMore});

  final List<SessionSummary> items;
  final int page;
  final bool hasMore;
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, HistoryState>(HistoryController.new);

/// Completed workouts, newest first. Reloaded when a workout is finished
/// (see ActiveSessionController.finish).
class HistoryController extends AsyncNotifier<HistoryState> {
  SessionsRepository get _repository => ref.read(sessionsRepositoryProvider);

  bool _loadingMore = false;

  @override
  Future<HistoryState> build() async {
    ref.watch(authControllerProvider.select((auth) => auth.value?.id));
    final first = await _repository.getHistory();
    return HistoryState(items: first.items, page: first.page, hasMore: first.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await _repository.getHistory(page: current.page + 1);
      state = AsyncData(HistoryState(
        items: [...current.items, ...next.items],
        page: next.page,
        hasMore: next.hasMore,
      ));
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    invalidateWorkoutStats(ref.invalidate);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(HistoryState(
      items: [...current.items.where((s) => s.id != id)],
      page: current.page,
      hasMore: current.hasMore,
    ));
  }
}

/// One past workout with all its sets (GET /api/sessions/{id}).
final pastSessionProvider = FutureProvider.autoDispose.family<WorkoutSession, String>(
  (ref, id) => ref.watch(sessionsRepositoryProvider).getSession(id),
);

/// Completed workouts per day of the current week (for the Home week strip).
/// [firstDayOfWeek] uses DateTime.weekday numbers (1 = Monday ... 7 = Sunday).
List<int> sessionsPerDay(List<SessionSummary> sessions, DateTime now, {int firstDayOfWeek = DateTime.sunday}) {
  final today = DateTime(now.year, now.month, now.day);
  final offset = (today.weekday - firstDayOfWeek) % 7;
  final weekStart = today.subtract(Duration(days: offset));

  final counts = List.filled(7, 0);
  for (final session in sessions) {
    final local = session.completedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final index = day.difference(weekStart).inDays;
    if (index >= 0 && index < 7) counts[index]++;
  }
  return counts;
}
