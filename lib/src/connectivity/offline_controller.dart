import 'package:flutter/material.dart';

class OfflineController {
  final BuildContext context;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  OfflineController({required this.context});

  Future retry() async {
    isLoading.value = true;
    Future.delayed(
      const Duration(seconds: 3),
      () {
        isLoading.value = false;
      },
    );
  }

  void dispose() {
    isLoading.dispose();
  }
}
