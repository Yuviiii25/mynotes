import 'package:mynotes/Services/auth/auth_user.dart';

abstract class AuthProvider{
  Future<void> initialize();
  AuthUser? get currentUSer;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}