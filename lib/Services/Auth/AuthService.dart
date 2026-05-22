import 'package:practice_app/Services/Auth/AuthProvider.dart';
import 'package:practice_app/Services/Auth/AuthUser.dart';
import 'package:practice_app/Services/Auth/FirebaseAuthProvider.dart';

class AuthService implements AuthProvider{
  final AuthProvider provider;
  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());
  @override
  Future<AuthUser> LogIn({
    required String email,
    required String password,
  }) =>
      provider.LogIn(
          email: email,
          password: password,
      );

  @override
  Future<void> LogOut() => provider.LogOut();

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) => provider.createUser(
      email: email,
      password: password,
  );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

}