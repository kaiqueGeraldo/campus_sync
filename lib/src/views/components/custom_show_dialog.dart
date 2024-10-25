import 'package:flutter/material.dart';

void customShowDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
  VoidCallback? onConfirm,
  String? cancelText,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: onConfirm,
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
