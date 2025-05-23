part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthRequest extends AuthEvent{
  final String username;
  final String password;
  AuthRequest({required this.username, required this.password});
}
