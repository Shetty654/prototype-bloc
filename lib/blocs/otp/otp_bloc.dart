import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:CAPO/data/repositories/auth/auth_repository.dart';

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
      await authRepository.sendOtp(phone: event.phone);
      emit(OtpSentSuccess(phone: event.phone));
    } catch (e) {
      emit(OtpSentFailed(message: e.toString()));
    }
  }

  Future<void> _onOtpVerifyPressed(
      OtpVerifyPressed event, Emitter<OtpState> emit) async {
    emit(OtpVerificationInProgress());
    try {
      await authRepository.verifyOtp(phone: event.phone, code: event.otp);
      emit(OtpVerificationSuccess());
    } catch (e) {
      emit(OtpVerificationFailed(message: e.toString()));
    }
  }
}
