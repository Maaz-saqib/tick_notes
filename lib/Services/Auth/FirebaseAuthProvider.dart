import 'package:firebase_core/firebase_core.dart';
import 'package:tick_notes/Services/Auth/AuthUser.dart';
import 'package:tick_notes/Services/Auth/Auth_Provider.dart';
import 'package:tick_notes/Services/Auth/AuthException.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import '../../firebase_options.dart';

class FirebaseAuthProvider implements Auth_Provider{
  @override
  Future<AuthUser> LogIn({
    required String email,
    required String password,
  }) async {
    try{
      await Future.delayed(const Duration(seconds: 2));
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
      );
      final user=currentUser;
      if(user != null){
        return user;
      }else{
        throw UserNotLoggedInAuthException();
      }
    }on FirebaseAuthException catch(e){
      if(e.code=='invalid-credential'){
       throw UserNotFoundAuthException();
      }else if(e.code=='wrong-password'){
        throw WrongPasswordAuthException();
      }else{
        throw GenericAuthException();
      }
    }catch(_){
      throw GenericAuthException();
    }
  }

  @override
  Future<void> LogOut() async{
    final user=FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      final user=currentUser;
      if(user != null){
        return user;
      }else{
        throw UserNotLoggedInAuthException();
      }
    }on FirebaseAuthException catch(e){
      if(e.code=='weak password'){
        throw WeakPasswordAuthException();
      }else if(e.code=='Email already in use'){
        throw EmailAlreadyInUseAuthException();
      }else if(e.code=='invalid-email'){
        throw InvalidEmailAuthException();
      }else{
        throw GenericAuthException();
      }
    }catch(_){
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user=FirebaseAuth.instance.currentUser;
    if(user != null){
      return AuthUser.fromFirebase(user);
    }else{
      return null;
    }
  }

  @override
  Future<void> sendEmailVerification() async{
    final user= FirebaseAuth.instance.currentUser;
    if(user != null){
      await user.sendEmailVerification();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    try{
      return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch(e){
      switch (e.code){
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }
  
}