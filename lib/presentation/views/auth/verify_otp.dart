import 'package:flutter/material.dart';

class VerifyOtp extends StatelessWidget {
  final String phone;
  const VerifyOtp({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    TextEditingController otpController = TextEditingController();
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: ElevatedButton(onPressed: () {

              }, child: Text('VERIFY OTP')),
            ),
          ],
        ),
      ),
    );
  }
}
