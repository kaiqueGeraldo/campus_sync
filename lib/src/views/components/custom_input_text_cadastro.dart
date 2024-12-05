import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputTextCadastro extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool enabled;

  const CustomInputTextCadastro({
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    this.validator,
    this.maxLength,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      maxLength: maxLength,
      keyboardType: keyboardType,
      enabled: enabled,
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
      ),
    );
  }
}
