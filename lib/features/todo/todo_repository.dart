import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';

part 'todo_repository.g.dart';

class TodoRepository {
  TodoRepository(this._db);
  final AppDatabase _db;

  Stream<List<Todo>> watchAll() {
    return (_db.select(_db.todos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isCompleted, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> add(TodosCompanion todo) => _db.into(_db.todos).insert(todo);

  Future<void> delete(int id) =>
      (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();

  Future<void> updateTodo(int id, TodosCompanion todo) =>
      (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(todo);

  Future<Todo?> getTodo(int id) =>
      (_db.select(_db.todos)..where((t) => t.id.equals(id))).getSingleOrNull();
}

@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return TodoRepository(db);
}
