import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/app_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cortracker360',
      debugShowCheckedModeBanner: false,
      theme: AppUtils.getAppTheme(),
      home: const SplashScreen(),
    );
  }
}
