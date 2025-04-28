import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthDataProvider{
  Future sendOtp({required String phone}) async {
    final uri = Uri.parse("http://192.168.1.36:8080/api/auth/sendotp");
    var body = jsonEncode({
      "phone": phone,
    });

    final response = await http.post(uri, body: body, headers: {
      "Content-Type": "application/json",  // Set the correct Content-Type
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to send OTP');
    }
  }


  Future verifyOtp({required String phone, required String code}) async {
    final uri = Uri.parse("http://192.168.1.36:8080/api/auth/verifyotp");
    var body = jsonEncode({
      "phone": phone,
      "code": code,
    });

    final response = await http.post(uri, body: body, headers: {
      "Content-Type": "application/json", 
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to verify OTP');
    }
  }
}