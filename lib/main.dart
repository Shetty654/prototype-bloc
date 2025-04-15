import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype_bloc/presentation/routes/app_router.dart';

void main(){
  runApp(MyApp());
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
