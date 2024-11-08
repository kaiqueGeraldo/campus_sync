import 'package:campus_sync/src/views/pages/forgot_password_page.dart';
import 'package:campus_sync/src/views/pages/initial_page.dart';
import 'package:campus_sync/src/views/pages/signin_page.dart';
import 'package:campus_sync/src/views/pages/signup_page.dart';
import 'package:flutter/material.dart';

class RouteGenerate {
  static const String routeSignIn = '/signin';
  static const String routeSignUp = '/signup';
  static const String routeForgotPassword = '/forgotpassword';
  static const String routeInitial = '/initial';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeSignIn:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
        );
      case routeSignUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
        );
      case routeForgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );
      case routeInitial:
        return MaterialPageRoute(
          builder: (_) => const InitialPage(),
        );
      default:
        return _notFoundPage();
    }
  }

  static Route<dynamic> _notFoundPage() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'CampusSync - 404',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: const Center(
            child: Text(
              'Página não encontrada!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
