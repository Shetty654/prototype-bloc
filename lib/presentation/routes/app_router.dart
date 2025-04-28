import 'package:flutter/material.dart';
import 'package:CAPO/presentation/views/auth/screens/verify_otp.dart';

import '../views/auth/screens/generate_otp.dart';
import '../views/auth/screens/sign_in.dart';
import '../views/home/screens/home.dart';

class AppRouter {
  static Route onGeneratedRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
      case '/verifyOtp':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => VerifyOtp(
                phone: args['phone'],
              ),
        );
      case '/signin':
        return MaterialPageRoute(
            builder: (_) => SignIn()
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
