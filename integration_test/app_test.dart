import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/features/todo/todo_list_screen.dart';
import 'package:tick_notes/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset SharedPreferences to clear onboarding state
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset Drift SQLite Database
    final db = AppDatabase();
    await db.transaction(() async {
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
    });
    await db.close();
  });

  group('TickNotes End-to-End Integration Tests', () {
    testWidgets('Flow 1: Create a Note and Verify it Appears', (WidgetTester tester) async {
      // 1. Launch App
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );
      
      // 2. Wait for splash screen animation to complete and transition to home/dashboard
      await tester.pumpAndSettle();

      // 3. Handle Onboarding tooltip overlay if it is showing
      final skipFinder = find.text('Skip');
      if (skipFinder.evaluate().isNotEmpty) {
        await tester.tap(skipFinder);
        await tester.pumpAndSettle();
      }

      // 4. Create Note (Tap the add icon button)
      final addNoteButton = find.byIcon(Icons.add);
      expect(addNoteButton, findsOneWidget);
      await tester.tap(addNoteButton);
      await tester.pumpAndSettle();

      // Find the Title TextField by hint text
      final titleField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'Title',
      );
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Integration Test Note');

      // Find the Body TextField by hint text
      final bodyField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'Start typing your note...',
      );
      expect(bodyField, findsOneWidget);
      await tester.enterText(bodyField, 'This is a test body');
      await tester.pumpAndSettle();

      // 5. Save Note (Tap the Back button on the AppBar)
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // 6. Verify Note is visible in the Notes grid view
      expect(find.text('Integration Test Note'), findsOneWidget);
    });

    testWidgets('Flow 2: Create a Task and Mark it Completed', (WidgetTester tester) async {
      // 1. Launch App
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Handle Onboarding tooltip overlay if showing
      final skipFinder = find.text('Skip');
      if (skipFinder.evaluate().isNotEmpty) {
        await tester.tap(skipFinder);
        await tester.pumpAndSettle();
      }

      // 2. Navigate to Tasks tab
      final tasksTab = find.text('Tasks');
      expect(tasksTab, findsOneWidget);
      await tester.tap(tasksTab);
      await tester.pumpAndSettle();

      // 3. Create Task
      final addTaskButton = find.byIcon(Icons.add_task);
      expect(addTaskButton, findsOneWidget);
      await tester.tap(addTaskButton);
      await tester.pumpAndSettle();

      // Find Title TextField
      final taskTitleField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'What needs to be done?',
      );
      expect(taskTitleField, findsOneWidget);
      await tester.enterText(taskTitleField, 'Buy Milk');
      await tester.pumpAndSettle();

      // Save the task by pressing check icon
      final saveButton = find.byIcon(Icons.check);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 4. Select "Upcoming" tab since task has no due date and belongs there
      final upcomingTab = find.text('Upcoming');
      expect(upcomingTab, findsOneWidget);
      await tester.tap(upcomingTab);
      await tester.pumpAndSettle();

      // Verify task creation
      expect(find.text('Buy Milk'), findsOneWidget);

      // 5. Find the checkbox next to "Buy Milk" and tap it
      final todoCard = find.ancestor(
        of: find.text('Buy Milk'),
        matching: find.byType(AnimatedTodoCard),
      );
      expect(todoCard, findsOneWidget);

      final checkbox = find.descendant(
        of: todoCard,
        matching: find.byType(AnimatedContainer),
      ).first;
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // 6. Navigate to Completed tab and verify the task displays there
      final completedTab = find.text('Completed');
      expect(completedTab, findsOneWidget);
      await tester.tap(completedTab);
      await tester.pumpAndSettle();

      expect(find.text('Buy Milk'), findsOneWidget);
    });
  });
}
