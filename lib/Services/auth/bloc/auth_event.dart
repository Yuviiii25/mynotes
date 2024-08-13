import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent{
  const AuthEventSendEmailVerification();
}

class AuthEventLogIn extends AuthEvent{
  final String email;
  final String password;

  AuthEventLogIn({required this.email, required this.password});
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String password;

  AuthEventRegister({required this.email, required this.password});
}

class AuthEventLogOut extends AuthEvent{
  const AuthEventLogOut();
}