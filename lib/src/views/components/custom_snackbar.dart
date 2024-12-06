import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? AppColors.errorColor,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: AppColors.buttonColor,
            )
          : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
