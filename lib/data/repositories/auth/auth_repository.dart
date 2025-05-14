import 'dart:async';
import 'package:flutter/material.dart';
import 'package:CAPO/data/providers/AuthDataProvider.dart';

class AuthRepository {
  final AuthDataProvider authDataProvider;

  AuthRepository({required this.authDataProvider});

  Future sendOtp({required String phone}) async {
    return await authDataProvider.sendOtp(phone: phone);
  }

  Future verifyOtp({required String phone, required String code}) async {
    return await authDataProvider.verifyOtp(phone: phone, code: code);
  }

  Future signIn({required String username, required String password}) async {
    return await authDataProvider.signIn(username: username, password: password);
  }
}
