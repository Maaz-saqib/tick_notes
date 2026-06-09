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
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        }else if(state is AuthStateLoggedOut){
          return const LoginView();
        }else{
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
