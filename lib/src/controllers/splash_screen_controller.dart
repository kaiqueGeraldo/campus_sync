import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_sync/src/views/pages/main/initial_page.dart';
import 'package:campus_sync/src/views/pages/auth/signin_page.dart';

class SplashScreenController {
  final ValueNotifier<bool> showText = ValueNotifier(false);
  bool _isDisposed = false;

  SplashScreenController() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!_isDisposed) {
      showText.value = true;
    }
  }

  Future<void> checkIfLoggedInAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    final isLoggedIn = token != null;

    await Future.delayed(const Duration(seconds: 5));
    if (!_isDisposed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isLoggedIn
              ? const InitialPage(
                  cameFromSignIn: true,
                )
              : const SignInPage(),
        ),
      );
    }
  }

  void dispose() {
    _isDisposed = true;
    showText.dispose();
  }
}
