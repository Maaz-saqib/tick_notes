import 'package:flutter/cupertino.dart';
import 'Generic_Dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context){
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content: 'Password reset link sent to your email',
    optionBuilder: () => {
      'Ok': null,
    },
  );
}