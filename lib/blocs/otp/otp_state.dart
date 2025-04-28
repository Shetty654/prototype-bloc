part of 'otp_bloc.dart';

@immutable
sealed class OtpState {}

final class OtpInitial extends OtpState{}

final class OtpSentInProgress extends OtpState {}

final class OtpVerificationInProgress extends OtpState{}

final class OtpSentSuccess extends OtpState{
  final String phone;
  OtpSentSuccess({required this.phone});
}

final class OtpVerificationSuccess extends OtpState{
}

final class OtpVerificationFailed extends OtpState{
  final String message;
  OtpVerificationFailed({required this.message});
}

final class OtpSentFailed extends OtpState{
  final String message;
  OtpSentFailed({required this.message});
}
