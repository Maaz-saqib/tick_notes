import 'package:flutter/cupertino.dart';
import 'package:tick_notes/Utilities/Dialog/Generic_Dialog.dart';

Future<bool> showDeleteDialog (BuildContext context){
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionBuilder: () => {
      'cancel': false,
      'Yes' : true,
    },
  ).then( (value) => value ?? false );
}