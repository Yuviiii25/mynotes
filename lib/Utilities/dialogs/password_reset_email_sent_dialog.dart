import 'package:flutter/material.dart';
import 'package:mynotes/Utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context){
  return showGenericDialog(context: context, title: 'Password Reset', content: 'We Have now sent you a password reset link.Please check email for more information', optionsBuilder: ()=>{
    'Ok':null,
  });
}