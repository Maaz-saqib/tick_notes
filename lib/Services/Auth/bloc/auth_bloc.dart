import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:practice_app/Services/Auth/Auth_Provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(Auth_Provider provider) : super(const AuthStateLoading ()) {
    // INITIALIZE
    on<AuthEventInitialize> ((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(null) );
      }else if(!user.isEmailVerified){
        emit(const AuthStateNeedsVerification());
      }else{
        emit(AuthStateLoggedIn(user));
      }
    });

    // LOG IN
    on<AuthEventLogIn>((event , emit) async {
      final email = event.email;
      final password = event.password;
      try{
        final user = await provider.LogIn(
            email: email,
            password: password,
        );
        emit(AuthStateLoggedIn(user));
      }on Exception catch (e){
        emit(AuthStateLoggedOut(e));
      }
    });

    //LOG OUT
    on<AuthEventLogOut>((event, emit) async{
      try{
        emit(const AuthStateLoading());
        await provider.LogOut();
        emit(const AuthStateLoggedOut(null));
      }on Exception catch(e){
        emit(AuthStateLoggedOutFailure(e));
      }
    });
  }
}