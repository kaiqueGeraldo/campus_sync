import 'package:campus_sync/src/controllers/splash_screen_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashScreenController _controller = SplashScreenController();

  @override
  void initState() {
    super.initState();
    _controller.checkIfLoggedInAndNavigate(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        image: const DecorationImage(
                            image: AssetImage('assets/images/logo.png')),
                        color: Colors.transparent),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _controller.showText,
                    builder: (context, showText, child) {
                      return AnimatedOpacity(
                        opacity: showText ? 1.0 : 0.0,
                        duration: const Duration(seconds: 1),
                        child: Text(
                          'CampusSync',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.1,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          onEnd: () => _controller.showText.value = true,
        ),
      ),
    );
  }
}
