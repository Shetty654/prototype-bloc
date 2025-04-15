part of 'otp_bloc.dart';

@immutable
sealed class OtpState {}

final class AuthLoading extends OtpState {}

final class OtpSentSuccessState extends OtpState{}

final class OtpVericationSuccessfulState extends OtpState{}

final class OtpVerificationFailedState extends OtpState{
  final String message;
  OtpVerificationFailedState({required this.message});
}

final class OtpSentFailedState extends OtpState{
  final String message;
  OtpSentFailedState({required this.message});
}
