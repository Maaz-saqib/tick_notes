import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practice_app/Views/LoginView.dart';
import 'package:practice_app/Views/RegisterView.dart';
import 'package:practice_app/Views/VerifyEmailView.dart';
import 'package:practice_app/core/theme/theme_notifier.dart';
import 'package:practice_app/features/notes/note_editor_screen.dart';
import 'package:practice_app/features/notes/notes_list_screen.dart';
import 'Constants/Routes.dart';
import 'Services/Auth/bloc/auth_bloc.dart';
import 'Services/Auth/bloc/auth_event.dart';
import 'Services/Auth/bloc/auth_state.dart';
import 'Views/forget_password_view.dart';
import 'helpers/loading/loading_screen.dart';
import 'package:practice_app/screens/animated_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return bloc.BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesListScreen();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgetPassword) {
          return const ForgetPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}