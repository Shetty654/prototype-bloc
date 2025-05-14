import 'dart:async';

import 'package:CAPO/data/repositories/auth/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC that handles user authentication logic.
///
/// Listens for [AuthEvent]s and emits [AuthState]s accordingly.
/// Uses [AuthRepository] to perform sign-in operations.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  /// Creates an [AuthBloc] with the given [authRepository].
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthRequest>(onAuthRequest);
  }

  /// Handles [AuthRequest] event.
  ///
  /// Emits:
  /// - [SignInInProgress] while the request is ongoing
  /// - [SignInSuccess] on successful login
  /// - [SignInFailure] if login fails
  Future<void> onAuthRequest(AuthRequest event, Emitter<AuthState> emit) async {
    emit(SignInInProgress());

    try {
      await authRepository.signIn(
        username: event.username,
        password: event.password,
      );
      await _secureStorage.write(key: "username", value: event.username);
      emit(SignInSuccess(username: event.username));
    } catch (e) {
      emit(SignInFailure(message: "Login failed. Please try again."));
    }
  }
}
