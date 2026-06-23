import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';

part 'notes_repository.g.dart';

class NotesRepository {
  NotesRepository(this._db);
  final AppDatabase _db;

  Stream<List<Note>> watchAll() {
    return (_db.select(_db.notes)
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> add(NotesCompanion note) => _db.into(_db.notes).insert(note);

  Future<void> delete(int id) =>
      (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();

  Future<void> updateNote(int id, NotesCompanion note) =>
      (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(note);

  Future<Note?> getNote(int id) =>
      (_db.select(_db.notes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Note>> getAll() => _db.select(_db.notes).get();
}

@riverpod
NotesRepository notesRepository(NotesRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return NotesRepository(db);
}
