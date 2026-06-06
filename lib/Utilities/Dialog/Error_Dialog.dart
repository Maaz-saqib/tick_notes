import 'package:flutter/cupertino.dart';
import 'package:practice_app/Utilities/Dialog/Generic_Dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
){
  return showGenericDialog(
      context: context,
      title: 'An error occured',
      content: text,
      optionBuilder: () => {
        'OK': null,
      },
  );
}
