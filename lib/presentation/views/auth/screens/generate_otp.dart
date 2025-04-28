import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:CAPO/blocs/otp/otp_bloc.dart';

class GenerateOtp extends StatelessWidget {
  const GenerateOtp({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpSentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP Sent to: ${state.phone}')),
          );
          Navigator.pushNamed(
            context,
            '/verifyOtp',
            arguments: {
              'phone': '+91' + phoneController.text.trim(),
            },
          );
        } else if (state is OtpSentFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)));
        } else if (state is OtpSentInProgress) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('sending otp...'))
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('PHONE VERIFICATION')),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your mobile number',
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    String phone = '+91' + phoneController.text.trim();
                    BlocProvider.of<OtpBloc>(context).add(
                        OtpSendPressed(phone: phone));
                  },
                  child: Text('SEND OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}