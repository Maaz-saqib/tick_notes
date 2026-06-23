import 'package:flutter/cupertino.dart';
import 'package:tick_notes/Utilities/Dialog/generic_dialog.dart';

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