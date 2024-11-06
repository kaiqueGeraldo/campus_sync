import 'package:campus_sync/src/views/components/custom_alert_dialog.dart';
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
      return CustomAlertDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        onCancel: onCancel,
        confirmText: confirmText,
        onConfirm: onConfirm!,
      );
    },
  );
}
