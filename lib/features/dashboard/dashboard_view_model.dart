import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notes/notes_repository.dart';
import '../todo/todo_repository.dart';

part 'dashboard_view_model.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  void build() {}

  Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_complete') ?? false;
    if (seen) return false;

    final notes = await ref.read(notesRepositoryProvider).getAll();
    final todos = await ref.read(todoRepositoryProvider).getAll();

    if (notes.isNotEmpty || todos.isNotEmpty) {
      await prefs.setBool('onboarding_complete', true);
      return false;
    }

    return true;
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }
}
