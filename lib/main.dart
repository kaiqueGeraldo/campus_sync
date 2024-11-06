import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/initial_page.dart';
import 'package:campus_sync/src/views/pages/signin_page.dart';
import 'package:campus_sync/src/views/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> checkIfLoggedIn(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token != null) {
      Navigator.of(context).pushReplacementNamed('/initial');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SignInPage(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundBlueColor,
          foregroundColor: AppColors.textColor,
        ),
      ),
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/initial': (context) => const InitialPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
