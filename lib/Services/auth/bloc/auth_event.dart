import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent{
  final String email;
  final String password;

  AuthEventLogIn({required this.email, required this.password});
}

class AuthEventLogOut extends AuthEvent{
  const AuthEventLogOut();
}