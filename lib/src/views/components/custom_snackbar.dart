import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(BuildContext context, String message, {Color? backgroundColor}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? AppColors.errorColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
