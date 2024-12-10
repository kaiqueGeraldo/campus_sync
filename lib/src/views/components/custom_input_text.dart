import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputText extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final int? maxLength;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const CustomInputText({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.isPassword = false,
    this.obscureText = false,
    this.onSuffixIconPressed,
    this.validator,
    this.maxLength,
    this.suffixIcon,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      style: const TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.greyColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textColor),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        counterText: '',
        suffixIcon: isPassword
            ? IconButton(
                color: AppColors.textColor,
                onPressed: onSuffixIconPressed,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : suffixIcon,
      ),
    );
  }
}
