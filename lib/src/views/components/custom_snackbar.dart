import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    String? actionLabel,
    Duration? duration,
    bool? showCloseButton,
    VoidCallback? onAction,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? AppColors.errorColor,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: textColor ?? AppColors.buttonColor,
            )
          : null,
      duration: duration ?? const Duration(seconds: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 3,
      ),
      behavior: SnackBarBehavior.floating,
      actionOverflowThreshold: 1,
      showCloseIcon: showCloseButton ?? true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
