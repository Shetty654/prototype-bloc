part of 'otp_bloc.dart';

@immutable
sealed class OtpEvent {}

class OtpSendPressed extends OtpEvent{}

class OtpVerifyPressed extends OtpEvent{}
