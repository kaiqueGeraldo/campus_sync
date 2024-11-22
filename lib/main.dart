import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/routes/route_generate.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundBlueColor,
          foregroundColor: AppColors.textColor,
        ),
      ),
      onGenerateRoute: RouteGenerate.generateRoute,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
