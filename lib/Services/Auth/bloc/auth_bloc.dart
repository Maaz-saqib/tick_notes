import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:practice_app/Services/Auth/Auth_Provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(Auth_Provider provider) : super(const AuthStateUninitialized (isLoading: true)) {
    //SEND EMAIL VERIFICATION
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    //REGISTRATION
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try{
        await provider.createUser(
            email: email,
            password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      }on Exception catch(e){
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });
    // INITIALIZE
    on<AuthEventInitialize> ((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      }else if(!user.isEmailVerified){
        emit(const AuthStateNeedsVerification(isLoading: false));
      }else{
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // LOG IN
    on<AuthEventLogIn>((event , emit) async {
      emit(const AuthStateLoggedOut(exception: null, isLoading: true, loadingText: 'Logging in...'));
      final email = event.email;
      final password = event.password;
      try{
        final user = await provider.LogIn(
            email: email,
            password: password,
        );

        if(!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        }else{
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }on Exception catch (e){
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
          ),
        );
      }
    });

    //LOG OUT
    on<AuthEventLogOut>((event, emit) async{
      try{
        await provider.LogOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      }on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}