import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputTextCadastro extends StatelessWidget {
  final TextEditingController controller;
  final String? field;
  final String labelText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets? padding;
  final bool isLoading;
  final BorderRadius? borderRadius;

  const CustomInputTextCadastro({
    super.key,
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    this.validator,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.padding,
    this.field,
    this.isLoading = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        maxLength: maxLength,
        keyboardType: keyboardType,
        enabled: isLoading ? false : enabled,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        cursorColor: AppColors.backgroundBlueColor,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        decoration: InputDecoration(
          label: Text(labelText),
          floatingLabelStyle: const TextStyle(
            color: AppColors.backgroundBlueColor,
          ),
          border: OutlineInputBorder(
            borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(10)),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(12)),
            borderSide: const BorderSide(color: AppColors.backgroundBlueColor),
          ),
          counterText: '',
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
