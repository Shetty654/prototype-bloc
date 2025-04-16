import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:prototype_bloc/data/repository/auth/auth_repository.dart';

part 'otp_event.dart';

part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthRepository authRepository;

  OtpBloc({required this.authRepository}) : super(OtpInitial()) {
    on<OtpSendPressed>(_onOtpSendPressed);
    on<OtpVerifyPressed>(_onOtpVerifyPressed);
  }

  Future<void> _onOtpSendPressed(
      OtpSendPressed event, Emitter<OtpState> emit) async {
    emit(OtpSentInProgress());
    try {
      final verificationId = await authRepository.sendCode(event.phone);
      emit(OtpSentSuccess(phone: event.phone, verificationId: verificationId));
    } catch (e) {
      emit(OtpSentFailed(message: e.toString()));
    }
  }

  Future<void> _onOtpVerifyPressed(
      OtpVerifyPressed event, Emitter<OtpState> emit) async {
    emit(OtpVerificationInProgress());

    try {
      final user = await authRepository.verifyCode(
        verificationId: event.verificationId,
        otp: event.otp,
      );
      emit(OtpVerificationSuccess(user: user));
    } catch (e) {
      emit(OtpVerificationFailed(message: e.toString()));
    }
  }
}
