import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:prototype_bloc/data/repository/auth/auth_repository.dart';
import 'package:prototype_bloc/presentation/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'blocs/auth/otp/otp_bloc.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLocator();

  runApp(MyApp());
}

void setupLocator() {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = getIt<AuthRepository>(); // ✅ Fetching from get_it

    return BlocProvider(
      create: (context) => OtpBloc(authRepository: authRepository),
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGeneratedRoute,
      ),
    );
  }
}

