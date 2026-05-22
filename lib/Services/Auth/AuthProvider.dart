import 'package:practice_app/Services/Auth/AuthUser.dart';

abstract class AuthProvider{
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

}