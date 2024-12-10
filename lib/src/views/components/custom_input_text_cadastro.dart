import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputTextCadastro extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInputTextCadastro({
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    this.validator,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    super.key,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLength: maxLength,
      keyboardType: keyboardType,
      enabled: enabled,
      inputFormatters: inputFormatters,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      decoration: InputDecoration(
        label: Text(labelText),
        floatingLabelStyle:
            const TextStyle(color: AppColors.backgroundBlueColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.backgroundBlueColor),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        counterText: '',
        suffixIcon: suffixIcon, 
      ),
    );
  }
}
