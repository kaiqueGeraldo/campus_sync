import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback onConfirm;
  final bool barrierDismissible;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundWhiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: const TextStyle(
              color: AppColors.buttonColor,
            ),
          ),
        ),
      ],
    );
  }
}
