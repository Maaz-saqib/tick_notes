import 'package:tick_notes/Services/Auth/AuthUser.dart';

abstract class Auth_Provider{
  Future<void> initialize();

  AuthUser? get currentUser;
  Future<AuthUser > LogIn({
    required String email,
    required String password,
  });
  Future<AuthUser > createUser({
    required String email,
    required String password,
  });

  Future<void > LogOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String email});

}

