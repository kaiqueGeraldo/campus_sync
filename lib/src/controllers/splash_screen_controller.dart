import 'dart:async';
import 'dart:convert';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
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

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];
      if (exp == null) {
        return true;
      }
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return currentTime >= exp;
    } catch (e) {
      return true;
    }
  }

  Future<void> checkIfLoggedInAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      await Future.delayed(const Duration(seconds: 5));
      if (!_isDisposed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } else if (!isTokenExpired(token)) {
      await Future.delayed(const Duration(seconds: 5));
      if (!_isDisposed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InitialPage(
              cameFromSignIn: true,
            ),
          ),
        );
      }
    } else {
      await Future.delayed(const Duration(seconds: 5));
      if (!_isDisposed) {
        await customShowDialog(
          context: context,
          title: 'Sessão Expirada',
          content: 'Sua sessão expirou. Por favor, faça login novamente.',
          confirmText: 'Fazer Login',
          onConfirm: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          },
        );
      }
    }
  }

  void dispose() {
    _isDisposed = true;
    showText.dispose();
  }
}
