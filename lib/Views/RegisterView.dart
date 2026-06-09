import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/Constants/Routes.dart';
import 'package:practice_app/Services/Auth/AuthService.dart';
import '../Services/Auth/AuthException.dart';
import '../Services/Auth/bloc/auth_bloc.dart';
import '../Services/Auth/bloc/auth_event.dart';
import '../Services/Auth/bloc/auth_state.dart';
import '../Utilities/Dialog/Error_Dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state is AuthStateRegistering){
          if(state.exception is WeakPasswordAuthException){
            await showErrorDialog(context, 'Weak Password');
          }else if(state.exception is EmailAlreadyInUseAuthException){
            await showErrorDialog(context, 'Email already in use');
          }else if(state.exception is InvalidEmailAuthException){
            await showErrorDialog(context, 'Invalid Email');
          }else if(state.exception is GenericAuthException){
            await showErrorDialog(context, 'Failed to Register');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('REGISTER'),),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  hintText: 'Enter your email here'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                  hintText: 'Enter your password here'),
            ),
            TextButton(onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              context.read<AuthBloc>().add(
                AuthEventRegister(
                  email,
                  password,
                ),
              );
            },
                child: const Text('Register')
            ),
            TextButton(onPressed: () {
              context.read<AuthBloc>().add(
                const AuthEventLogOut(),
              );
            },
                child: const Text('Already Registered? Login HERE!'))
          ],
        ),
      ),
    );
  }
}
