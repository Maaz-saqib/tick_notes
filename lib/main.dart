import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_app/Views/LoginView.dart';
import 'package:practice_app/Views/RegisterView.dart';
import 'package:practice_app/Views/VerifyEmailView.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(

    title: 'Flutter Demo',
    theme: ThemeData(

      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    home: const HomePage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView(),
    },
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if(user != null){
              if(user.emailVerified){
                print('Email is verified');
              }else{
                return const VerifyEmailView();
              }
            }else{
              return const LoginView();
            }
            return const Text('DONE');

            default:
              return const CircularProgressIndicator();
          }
        }
    );
  }
}






