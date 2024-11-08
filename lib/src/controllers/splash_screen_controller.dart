import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_sync/src/views/pages/initial_page.dart';
import 'package:campus_sync/src/views/pages/signin_page.dart';

class SplashScreenController {
  final ValueNotifier<bool> showText = ValueNotifier(false);

  SplashScreenController() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 4));
    showText.value = true;
  }

  Future<void> checkIfLoggedInAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    final isLoggedIn = token != null;

    await Future.delayed(const Duration(seconds: 5));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            isLoggedIn ? const InitialPage() : const SignInPage(),
      ),
    );
  }

  void dispose() {
    showText.dispose();
  }
}
