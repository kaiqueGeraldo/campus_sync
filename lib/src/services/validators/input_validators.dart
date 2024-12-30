import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputValidators {
  // Validação de CPF
  static bool validateCpfLogic(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(value)) {
      return false;
    }
    return _isValidCpf(value);
  }

  static bool _isValidCpf(String cpf) {
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

  // Validação de CNPJ
  static bool validateCnpjLogic(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length != 14 || RegExp(r'^(\d)\1*$').hasMatch(value)) {
      return false;
    }
    return _isValidCnpj(value);
  }

  static bool _isValidCnpj(String cnpj) {
    int calculateDigit(List<int> digits, List<int> weights) {
      int sum = 0;
      for (int i = 0; i < digits.length; i++) {
        sum += digits[i] * weights[i];
      }
      int remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final digits = cnpj.split('').map(int.parse).toList();

    final firstCheckDigit = calculateDigit(
        digits.sublist(0, 12), [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    if (firstCheckDigit != digits[12]) {
      return false;
    }

    final secondCheckDigit = calculateDigit(
        digits.sublist(0, 13), [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    return secondCheckDigit == digits[13];
  }

  // Validação de Email
  static bool validateEmailLogic(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|outlook\.com)$')
        .hasMatch(value);
  }

  /// Formatter para Mensalidade (Moeda)
  static TextInputFormatter currencyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (newText.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      double value = double.tryParse(newText) ?? 0;
      String formatted = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(value / 100);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Método para criar ValueNotifier para validações dinâmicas
  static void updateFieldNotifier({
    required TextEditingController controller,
    required ValueNotifier<bool> notifier,
    required bool Function(String) validationLogic,
  }) {
    final text = controller.text;
    notifier.value = text.isNotEmpty && validationLogic(text);
  }
}
