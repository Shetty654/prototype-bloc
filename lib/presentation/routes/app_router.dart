import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype_bloc/presentation/views/auth/verify_otp.dart';

import '../views/auth/generate_otp.dart';
import '../views/home/home.dart';

class AppRouter {
  static Route onGeneratedRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => GenerateOtp());
      case '/verifyOtp':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => VerifyOtp(
                phone: args['phone'],
                verificationId: args['verificationId'],
              ),
        );
      case '/home':
        return MaterialPageRoute(builder: (_) => Home());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
