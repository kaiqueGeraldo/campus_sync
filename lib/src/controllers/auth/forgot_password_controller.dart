import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

final formKeyPassword = GlobalKey<FormState>();

class ForgotPasswordController {
  final BuildContext context;
  final formKey = formKeyPassword;
  final TextEditingController confirmCPFController =
      MaskedTextController(mask: '000.000.000-00');
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmNovaSenhaController =
      TextEditingController();
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isCpfValid = ValueNotifier(false);

  ForgotPasswordController({required this.context});

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (formKey.currentState?.validate() ?? false) {
      String cpf = confirmCPFController.text.replaceAll(RegExp(r'[^0-9]'), '');

      isLoading.value = true;

      if (novaSenhaController.text != confirmNovaSenhaController.text) {
        CustomSnackbar.show(context, 'As senhas não coincidem!');
        _setLoading(false);
        return;
      }

      bool cpfExists = await ApiService().checkCpfExists(cpf);
      if (!cpfExists) {
        CustomSnackbar.show(context, 'CPF não encontrado!');
        _setLoading(false);
        return;
      }

      final bool passwordChanged =
          await ApiService().resetPassword(cpf, novaSenhaController.text);

      if (passwordChanged) {
        CustomSnackbar.show(context, 'Senha alterada com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(context, 'Erro ao trocar a senha!');
      }

      isLoading.value = false;
    }
  }

  void _setLoading(bool value) {
    isLoading.value = value;
    (context as Element).markNeedsBuild();
  }

  String? validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo CPF é obrigatório';
    } else if (!validateCpfLogic(value)) {
      return 'CPF inválido';
    }
    return null;
  }

   void updateCpfNotifier() {
    final text = confirmCPFController.text;
    isCpfValid.value = text.isNotEmpty && validateCpfLogic(text);
  }

   bool validateCpfLogic(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(value)) {
      return false;
    }
    return _isValidCpf(value);
  }

  bool _isValidCpf(String cpf) {
    int calculateDigit(List<int> digits, int factor) {
      int sum = 0;
      for (final digit in digits) {
        sum += digit * factor--;
      }
      int remainder = (sum * 10) % 11;
      return remainder == 10 ? 0 : remainder;
    }

    final digits = cpf.split('').map(int.parse).toList();
    final digit1 = calculateDigit(digits.sublist(0, 9), 10);
    final digit2 = calculateDigit(digits.sublist(0, 10), 11);

    return digit1 == digits[9] && digit2 == digits[10];
  }

  void dispose() {
    confirmCPFController.dispose();
    novaSenhaController.dispose();
    confirmNovaSenhaController.dispose();
    obscurePassword.dispose();
    obscureConfirmPassword.dispose();
    isLoading.dispose();
    isCpfValid.dispose();
  }
}
