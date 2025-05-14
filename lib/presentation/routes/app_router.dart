import 'package:CAPO/presentation/views/project.dart';
import 'package:flutter/material.dart';
import 'package:CAPO/presentation/views/auth/screens/verify_otp.dart';

import '../views/auth/screens/generate_otp.dart';
import '../views/auth/screens/sign_in.dart';
import '../views/home/screens/home.dart';

class AppRouter {
  static Route onGeneratedRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => SignIn());
      case '/verifyOtp':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => VerifyOtp(phone: args['phone']),
        );
      case '/signin':
        return MaterialPageRoute(builder: (context) => SignIn());
      case '/project':
        return MaterialPageRoute(builder: (context) => Project());
      case '/home':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => Home(
            projectName: args['projectName'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}