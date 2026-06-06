import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:practice_app/Services/Auth/AuthService.dart';
import 'package:practice_app/Views/LoginView.dart';
import 'package:practice_app/Views/RegisterView.dart';
import 'package:practice_app/Views/VerifyEmailView.dart';
import 'Constants/Routes.dart';
import 'Views/Notes/NewNotesView.dart';
import 'Views/Notes/NotesView.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(

    title: 'Flutter Demo',
    theme: ThemeData(

      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      newNoteRoute : (context) => const NewNoteView(),
    },
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if(user != null){
              if(user.isEmailVerified){
                return const NotesView();
              }else{
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
              return const CircularProgressIndicator();
          }
        }
    );
  }
}

