import 'package:CAPO/blocs/auth/auth_bloc.dart';
import 'package:CAPO/blocs/home/dashboard/dashboard_bloc.dart';
import 'package:CAPO/blocs/home/home_bloc.dart';
import 'package:CAPO/blocs/otp/otp_bloc.dart';
import 'package:CAPO/blocs/project/project_bloc.dart';
import 'package:CAPO/data/providers/DashboardDataProvider.dart';
import 'package:CAPO/data/repositories/home/dashboard/dashboard_repository.dart';
import 'package:CAPO/presentation/views/home/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:CAPO/data/providers/AuthDataProvider.dart';
import 'package:CAPO/data/repositories/auth/auth_repository.dart';
import 'package:CAPO/presentation/routes/app_router.dart';

import 'blocs/home/chart/chart_bloc.dart';
import 'data/providers/ProjectDataProvider.dart';
import 'data/repositories/project/project_repository.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Providers
  getIt.registerSingleton<AuthDataProvider>(AuthDataProvider());
  getIt.registerSingleton<ProjectDataProvider>(ProjectDataProvider());
  getIt.registerSingleton<DashboardDataProvider>(DashboardDataProvider());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(authDataProvider: getIt<AuthDataProvider>()),
  );
  getIt.registerSingleton<ProjectRepository>(
    ProjectRepository(projectDataProvider: getIt<ProjectDataProvider>()),
  );
  getIt.registerSingleton<DashboardRepository>(
    DashboardRepository(dashboardDataProvider: getIt<DashboardDataProvider>()),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => getIt<AuthRepository>(),
        ),
        RepositoryProvider<ProjectRepository>(
          create: (_) => getIt<ProjectRepository>(),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (_) => getIt<DashboardRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              dashboardRepository: context.read<DashboardRepository>(),
            ),
          ),
          BlocProvider<ProjectBloc>(
            create: (context) => ProjectBloc(
              projectRepository: context.read<ProjectRepository>(),
            )..add(ProjectListRequested()),
          ),
          BlocProvider<ChartBloc>(
            create: (context) => ChartBloc(),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              dashboardBloc: BlocProvider.of<DashboardBloc>(context),
              chartBloc: BlocProvider.of<ChartBloc>(context),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGeneratedRoute,
      initialRoute: '/signin',
    );
  }
}