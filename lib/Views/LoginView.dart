import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/Constants/Routes.dart';
import '../Services/Auth/AuthException.dart';
import '../Services/Auth/bloc/auth_bloc.dart';
import '../Services/Auth/bloc/auth_event.dart';
import '../Utilities/Dialog/Error_Dialog.dart';

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
              context.read<AuthBloc>().add(
                AuthEventLogIn(
                  email,
                  password,
                ),
              );
            } on UserNotFoundAuthException {
              if (!context.mounted) return;
              await showErrorDialog(
                context,
                'User Not Found',
              );
            } on WrongPasswordAuthException {
              if (!context.mounted) return;
              await showErrorDialog(
                context,
                'Wrong Credentials',
              );
            } on GenericAuthException {
              if (!context.mounted) return;
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

