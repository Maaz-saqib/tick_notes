import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';

part 'pomodoro_repository.g.dart';

class PomodoroRepository {
  PomodoroRepository(this._db);
  final AppDatabase _db;

  Stream<List<PomodoroSession>> watchAll() {
    return (_db.select(_db.pomodoroSessions)
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<PomodoroSession>> getSessionsInPastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.pomodoroSessions)
          ..where((t) => t.startTime.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.asc)]))
        .get();
  }

  Stream<List<PomodoroSession>> watchSessionsInPastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.pomodoroSessions)
          ..where((t) => t.startTime.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<int> add(PomodoroSessionsCompanion session) =>
      _db.into(_db.pomodoroSessions).insert(session);
}

@riverpod
PomodoroRepository pomodoroRepository(PomodoroRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return PomodoroRepository(db);
}
