import 'package:CAPO/blocs/otp/otp_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:CAPO/data/providers/AuthDataProvider.dart';
import 'package:CAPO/data/repositories/auth/auth_repository.dart';
import 'package:CAPO/presentation/routes/app_router.dart';

final GetIt getIt = GetIt.instance;
final authDataProvider = AuthDataProvider();

void main() async {
  setupLocator();
  runApp(
    RepositoryProvider(
      create: (_) => AuthRepository(authDataProvider: authDataProvider),
      child: BlocProvider<OtpBloc>(
        create: (context) => OtpBloc(authRepository: getIt<AuthRepository>()),
        child: const MyApp(),
      ),
    ),
  );
}

void setupLocator() {
  getIt.registerSingleton<AuthDataProvider>(authDataProvider);
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(authDataProvider: authDataProvider),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: AppRouter.onGeneratedRoute,
    );
  }
}