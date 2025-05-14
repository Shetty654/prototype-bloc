part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class SignInSuccess extends AuthState{
  final String username;
  SignInSuccess({required this.username});
}

final class SignInFailure extends AuthState{
  final String message;
  SignInFailure({required this.message});
}

final class SignInInProgress extends AuthState{}