part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class SignInSuccess extends AuthState{}

final class SignInFailure extends AuthState{}

final class SignInInProgress extends AuthState{}