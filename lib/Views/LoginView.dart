import 'package:flutter/material.dart';
import 'package:practice_app/Constants/Routes.dart';
import 'package:practice_app/Services/Auth/AuthService.dart';
import '../Services/Auth/AuthException.dart';
import '../Utilities/ShowErrorDialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email=TextEditingController();
    _password=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOGIN'), ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration( hintText: 'Enter your email here'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter your password here'),
          ),
          TextButton(onPressed: () async {
            final email=_email.text;
            final password=_password.text;
            try{
              await AuthService.firebase().LogIn(
                email: email,
                password: password,
              );
              final user= AuthService.firebase().currentUser;
              if(user ?.isEmailVerified ?? false){
                // user's email is verified
                Navigator.of(context)
                .pushNamedAndRemoveUntil(
                  notesRoute,
                  (route) => false,
                );
              }else{
                //user's email is not verified
                Navigator.of(context)
                .pushNamedAndRemoveUntil(
                  verifyEmailRoute,
                  (route) => false,
                );
              }

            }on UserNotFoundAuthException{
              await showErrorDialog(
                  context,
                  'User Not Found',
              );
            }on WrongPasswordAuthException{
              await showErrorDialog(
                context,
                'Wrong Credentials',
              );
            }on GenericAuthException{
              await showErrorDialog(
                context,
                'Authentication Error',
              );
            }
          },
              child: const Text('Login')
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
              );
            },
            child: Text('No Registered yet? Register Here'),
          )
        ],
      ),
    );
  }
}

