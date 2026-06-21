import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick_notes/core/theme/theme_notifier.dart';
import 'package:tick_notes/core/notifications/notification_service.dart';
import 'package:tick_notes/features/notes/note_editor_screen.dart';
import 'package:tick_notes/features/todo/todo_editor_screen.dart';
import 'package:tick_notes/features/dashboard/dashboard_screen.dart';
import 'Constants/Routes.dart';
import 'package:tick_notes/screens/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Tick Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeSettings.seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeSettings.seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeSettings.themeMode,
      home: const AnimatedSplashScreen(),
      routes: {
        createOrUpdateNoteRoute: (context) => const NoteEditorScreen(),
        createOrUpdateTodoRoute: (context) => const TodoEditorScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}