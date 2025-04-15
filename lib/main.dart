import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prototype_bloc/presentation/routes/app_router.dart';

import 'blocs/auth/otp/otp_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(),
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGeneratedRoute,
      ),
    );
  }
}
