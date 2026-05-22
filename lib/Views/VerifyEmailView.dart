import 'package:flutter/material.dart';
import 'package:practice_app/Constants/Routes.dart';
import 'package:practice_app/Services/Auth/AuthService.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Verify Email'),),
      body: Column( children: [
        const Text(" We've sent an email verification in your email address. PLease verify it!"),
        const Text(" If you haven't received a verification email yet, press the button below"),
        TextButton(onPressed: () async {
          await AuthService.firebase().sendEmailVerification();
        },
            child: const Text('Send Email Verification')),
        TextButton(onPressed: () async{
          await AuthService.firebase().LogOut();
          Navigator.of(context).pushNamedAndRemoveUntil(
            registerRoute,
            (route) => false,
          );
        },
            child: const Text('Restart'),
        )
      ],),
    );
  }
}
