import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_app/Services/Auth/AuthException.dart';
import 'package:practice_app/Services/Auth/AuthUser.dart';
import 'package:test/test.dart';

void main(){
  group('Mock Authentication', () {
    final provider= MockAuthProvider();

    test('Should Not be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', (){
      expect(
        provider.LogOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', (){
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to login function', () async{
      final badEmailUser= provider.createUser(
        email: 'maazsaqib@gmail.com',
        password: 'maaz231',
      );
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>() ));

      final badPasswordUser= provider.createUser(
        email: 'maaz@gmail.com',
        password: 'maaz321',
      );
      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>() ));

      final user= await provider.createUser(
        email: 'maaz',
        password: 'maaz231',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Login user should be able to get verified', (){
      provider.sendEmailVerification();
      final user=provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to get logged out and log in again', () async{
      await provider.LogOut();
      await provider.LogIn(
          email: 'email',
          password: 'password',
      );
      final user =provider.currentUser;
      expect(user, isNotNull);
    });

  });
}


class NotInitializedException implements Exception{}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;


  Future<AuthUser> LogIn({
    required String email,
    required String password,
  }) {
    if(!isInitialized) throw NotInitializedException();
    if(email == 'maazsaqib@gmail.com') throw UserNotFoundAuthException();
    if(password == 'maaz321') throw WrongPasswordAuthException();
    const user= AuthUser(
        isEmailVerified: false,
        email: 'maazsaqib@gmail.com',
        id: 'my_id',
    );
    _user=user;

    return Future.value(user);
  }

  Future<void> LogOut() async {
    if(!isInitialized) throw NotInitializedException();
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return LogIn(
        email: email,
        password: password,
    );
  }

  AuthUser? get currentUser => _user;

  Future<void> sendEmailVerification() async {
    if(!isInitialized) throw NotInitializedException();
    final user= _user;
    if(user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
        isEmailVerified: true,
        email: 'maazsaqib@gmail.com',
        id: 'my_id',
    );
    _user = newUser;
  }

  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized=true;
  }

  @override
  String get providerId => throw UnimplementedError();

}