import 'package:flutter/cupertino.dart';
import 'package:practice_app/Services/Auth/AuthUser.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({required this.isLoading, this.loadingText='please wait a moment...'});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateRegistering extends AuthState{
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required isLoading}) : super(isLoading: isLoading);
}

class AuthStateForgetPassword extends AuthState{
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgetPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
}

class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required super.isLoading});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin{
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}
