import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/Services/auth/auth_exceptions.dart';
import 'package:mynotes/Services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/Services/auth/bloc/auth_event.dart';
import 'package:mynotes/Services/auth/bloc/auth_state.dart';
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
    _password = TextEditingController();
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async{
      if (state is AuthStateLoggedOut) {
        if (state.exception is UserNotFoundAuthException) {
          await showErrorDialog(context, 'Cannot find user with the entered credentials!');
        } else if (state.exception is WrongPasswordAuthException) {
          await showErrorDialog(context, 'Wrong Credentials');
        } else if (state.exception is GenericAuthExceptions) {
          await showErrorDialog(context, 'Authentication Error');
        }
       }
    },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                  'Please login to your account in order to interact with your notes!'
              ),
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter Your email here',
                ),
              ),
              TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter Your password here',
                  )),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventLogIn(email: email, password: password));
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventForgotPassword());
                },
                child: const Text('Forgot Password'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Not Registered Yet? Register Here!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
