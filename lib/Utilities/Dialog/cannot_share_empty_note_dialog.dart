import 'package:flutter/cupertino.dart';
import 'package:tick_notes/Utilities/Dialog/Generic_Dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'sharing',
      content: 'You cannot share and empty note',
      optionBuilder: () =>
      {
        'OK': null,
      }
  );
}