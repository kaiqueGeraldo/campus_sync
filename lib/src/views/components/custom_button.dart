import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final Color backgroundColor;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.buttonColor,
    this.width = 300,
    this.height = 50,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.8),
          disabledForegroundColor: AppColors.textColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textColor,
              ),
            ),
            if (isLoading) const SizedBox(width: 10),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
