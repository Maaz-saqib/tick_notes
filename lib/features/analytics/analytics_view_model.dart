import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../pomodoro/pomodoro_repository.dart';
import '../../core/database/app_database.dart';

part 'analytics_view_model.g.dart';

class DailyFocusStats {
  final DateTime date;
  final int totalMinutes;
  final List<PomodoroSession> sessions;

  DailyFocusStats({
    required this.date,
    required this.totalMinutes,
    required this.sessions,
  });
}

@riverpod
class AnalyticsViewModel extends _$AnalyticsViewModel {
  @override
  Stream<List<DailyFocusStats>> build() {
    final repository = ref.watch(pomodoroRepositoryProvider);
    return repository.watchSessionsInPastDays(30).map((rawSessions) {
      // Group sessions by day (ignoring hours/minutes)
      final Map<String, List<PomodoroSession>> grouped = {};
      for (final session in rawSessions) {
        final key = _formatDateKey(session.startTime);
        grouped.putIfAbsent(key, () => []).add(session);
      }

      final List<DailyFocusStats> stats = [];
      final now = DateTime.now();

      // Fill continuous 30-day timeline
      for (int i = 29; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final key = _formatDateKey(targetDate);
        final daySessions = grouped[key] ?? [];
        final totalMinutes = daySessions.fold<int>(0, (sum, item) => sum + item.durationMinutes);

        stats.add(DailyFocusStats(
          date: targetDate,
          totalMinutes: totalMinutes,
          sessions: daySessions,
        ));
      }

      return stats;
    });
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
