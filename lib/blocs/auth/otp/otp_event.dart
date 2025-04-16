part of 'otp_bloc.dart';

@immutable
sealed class OtpEvent {}

class OtpSendPressed extends OtpEvent{
  String phone;
  OtpSendPressed({required this.phone});
}

class OtpVerifyPressed extends OtpEvent{
  String otp;
  String verificationId;
  OtpVerifyPressed({required this.otp, required this.verificationId});
}
