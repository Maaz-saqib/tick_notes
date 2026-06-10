import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/Services/Auth/FirebaseAuthProvider.dart';
import 'package:practice_app/Views/LoginView.dart';
import 'package:practice_app/Views/RegisterView.dart';
import 'package:practice_app/Views/VerifyEmailView.dart';
import 'Constants/Routes.dart';
import 'Services/Auth/bloc/auth_bloc.dart';
import 'Services/Auth/bloc/auth_event.dart';
import 'Services/Auth/bloc/auth_state.dart';
import 'Views/Notes/create_update_notes_view.dart';
import 'Views/Notes/NotesView.dart';
import 'helpers/loading/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(

    title: 'Flutter Demo',
    theme: ThemeData(

      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateNoteRoute : (context) => const CreateUpdateNoteView(),
    },
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state.isLoading){
          LoadingScreen().show(
            context: context,
            text: state.loadingText?? 'Please wait a moment',
          );
        }else{
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        }else if(state is AuthStateLoggedOut){
          return const LoginView();
        }else if(state is AuthStateRegistering) {
          return const RegisterView();
        }else{
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
