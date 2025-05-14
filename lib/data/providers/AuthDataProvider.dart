import 'dart:convert';

import 'package:CAPO/constants/constants.dart';
import 'package:http/http.dart' as http;

class AuthDataProvider{
  Future sendOtp({required String phone}) async {
    final uri = Uri.parse("${Constants.BASE_URL}auth/sendotp");
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
    final uri = Uri.parse("${Constants.BASE_URL}auth/verifyotp");
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

  /// Sends a sign-in request to the CAPO backend.
  ///
  /// Takes a [username] and [password], sends a POST request to the CAPO
  /// sign-in endpoint, and returns the response body on success.
  ///
  /// Throws an [Exception] if authentication fails.
  Future signIn({required String username, required String password}) async {
    final uri = Uri.parse("${Constants.BASE_URL}auth/signin");
    var body = jsonEncode({
      "username": username,
      "password": password
    });
    final response = await http.post(uri, body: body, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to authenticate');
    }
  }
}