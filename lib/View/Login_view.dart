import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_exceptions.dart';
import 'package:mynotes/Services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/Services/auth/bloc/auth_event.dart';
import 'package:mynotes/Utilities/dialogs/error_dialog.dart';

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
    _email = TextEditingController();
    _password =TextEditingController();
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
    appBar: AppBar(title: const Text('Login'),),
     body: Column(
              children: [
            TextField(controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Enter Your email here',),),
            TextField(controller: _password,
                      obscureText:true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(hintText: 'Enter Your password here',)),
            TextButton(onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try{
                context.read<AuthBloc>().add(
                  AuthEventLogIn(email: email, password: password)
                );
              } on UserNotFoundAuthException{
                  await showErrorDialog(context, 'User not found!');
              } on WrongPasswordAuthException{
                  await showErrorDialog(context, 'Wrong Password');
              }on GenericAuthExceptions{
                  await showErrorDialog(context, 'Authentication Error');
              }
            },child: const Text('Login'),),
            TextButton(onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false,);
            }, 
            child: const Text('Not Registered Yet? Register Here!'),
            )
          ], 
        ),
   );
  } 
}

