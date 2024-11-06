import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/initial_page.dart';
import 'package:campus_sync/src/views/pages/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loggedIn = false;
  // ignore: unused_field
  bool _finishedSplash = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
    _startSplashAnimation();
  }

  Future<void> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    _loggedIn = token != null;
  }

  void _startSplashAnimation() async {
    await Future.delayed(const Duration(seconds: 4));
    setState(() => _finishedSplash = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            _loggedIn ? const InitialPage() : const SignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlueColor,
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.2, end: 1.0),
          curve: Curves.easeOutExpo,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fill,
                      width: 450,
                      height: 400,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _showText ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: const Text(
                      'CampusSync',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          onEnd: () {
            setState(() {
              _showText = true;
            });
          },
        ),
      ),
    );
  }
}
