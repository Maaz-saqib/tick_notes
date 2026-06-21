import 'package:flutter/cupertino.dart';
import 'package:tick_notes/Utilities/Dialog/Generic_Dialog.dart';

Future<bool> showLogOutDialog (BuildContext context){
  return showGenericDialog(
      context: context,
      title: 'Log Out',
      content: 'Are you sure you want to log out?',
      optionBuilder: () => {
        'cancel': false,
        'Log Out' : true,
      },
  ).then( (value) => value ?? false );
}