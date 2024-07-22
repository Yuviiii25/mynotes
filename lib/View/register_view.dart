import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_exceptions.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Utilities/show_error_dialog.dart';


class RegisterView extends StatefulWidget {
  const 
  RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

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
      appBar: AppBar(title: const Text('Register'),),
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
                await AuthService.firebase().createUser(email: email, password: password);
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(VerifyEmailRoute);
              } on WeakPasswordAuthException{
                await showErrorDialog(context, "Weak Password");
              } on EmailAlreadyInUSeAuthException{
                await showErrorDialog(context, 'Email is already in use');
              } on InvalidEmailAuthException{
                await showErrorDialog(context, 'Invalid email');
              } on GenericAuthExceptions{
                await showErrorDialog(context, 'Authentication Error');
              }
            },
            child: const Text('Register'),),
            TextButton(onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false,);
          }, 
          child: const Text('Already a User? Sign in'),
          )
          ], 
        ),
     );
  }
  
}

