import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenerateOtp extends StatelessWidget {
  const GenerateOtp({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('PHONE VERIFICATION'),
      ),
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
                    hintText: 'Enter your mobile number'
                ),),
            ),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: ElevatedButton(onPressed: () {

              }, child: Text('SEND OTP')),
            ),
          ],
        ),
      ),
    );
  }
}
