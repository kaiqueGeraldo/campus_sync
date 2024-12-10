import 'package:campus_sync/src/connectivity/offline_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:flutter/material.dart';

class OfflinePage extends StatefulWidget {
  final VoidCallback onRetry;
  final bool isLoading;

  const OfflinePage({
    super.key,
    required this.onRetry,
    required this.isLoading,
  });

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  late final OfflineController controller;

  @override
  void initState() {
    super.initState();
    controller = OfflineController(context: context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/offline_image.png',
                  height: 150,
                ),
              ),
              const Text(
                "Conecte-se com a Internet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Você está offline. Verifique sua conexão.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isLoading,
                builder: (context, isLoading, _) {
                  return CustomButton(
                    text: 'Clique para recarregar',
                    isLoading: isLoading,
                    onPressed: controller.retry,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
