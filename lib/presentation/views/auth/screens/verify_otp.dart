import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:CAPO/blocs/otp/otp_bloc.dart';

class VerifyOtp extends StatelessWidget {
  final String phone;

  const VerifyOtp(
      {super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    TextEditingController otpController = TextEditingController();

    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if(state is OtpVerificationInProgress){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('verifying otp...'))
          );
        }
        if(state is OtpVerificationSuccess){
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            ModalRoute.withName('/home'),
          );
        }
        if(state is OtpVerificationFailed){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message))
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('OTP VERIFY'),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: otpController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter the otp sent to ${phone}'
                  ),),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 12),
                child: ElevatedButton(onPressed: () {
                  String otp = otpController.text;
                  BlocProvider.of<OtpBloc>(context).add(
                    OtpVerifyPressed(phone: phone, otp: otp),
                  );
                }, child: Text('VERIFY OTP')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
