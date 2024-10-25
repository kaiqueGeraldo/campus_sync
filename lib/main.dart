import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/initial_page.dart';
import 'package:campus_sync/src/views/pages/signin_page.dart';
import 'package:campus_sync/src/views/pages/signup_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
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
    ),
  );
}
