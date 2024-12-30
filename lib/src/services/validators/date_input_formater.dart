import 'package:flutter/services.dart';

class DateTextInputFormatter extends TextInputFormatter {
  final bool isDataNascimento;

  DateTextInputFormatter({this.isDataNascimento = false});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Impede o primeiro dígito do dia ser maior que 3
    if (newText.isNotEmpty && int.tryParse(newText[0]) != null) {
      if (int.parse(newText[0]) > 3) {
        newText = oldValue.text;
      }
    }

    // Impede que o segundo dígito do dia seja maior que 9
    if (newText.length > 1 && int.tryParse(newText[1]) != null) {
      if (int.parse(newText[1]) > 9) {
        newText = oldValue.text;
      }
    }

    // Impede que o segundo dígito do dia seja maior que 1, se o primeiro dígito for 3
    if (newText.length > 1 && int.tryParse(newText[0]) == 3) {
      if (int.parse(newText[1]) > 1) {
        newText = oldValue.text;
      }
    }

    // Impede o primeiro dígito do mês ser maior que 1
    if (newText.length > 3 && int.tryParse(newText[3]) != null) {
      if (int.parse(newText[3]) > 1) {
        newText = oldValue.text;
      }
    }

    // Impede que o segundo dígito do mês seja maior que 9
    if (newText.length > 4 && int.tryParse(newText[4]) != null) {
      if (int.parse(newText[4]) > 9) {
        newText = oldValue.text;
      }
    }

    // Impede que o segundo dígito do mês seja maior que 2, se o primeiro dígito for 1
    if (newText.length > 4 && int.tryParse(newText[3]) == 1) {
      if (int.parse(newText[4]) > 2) {
        newText = oldValue.text;
      }
    }

    // Preenche automaticamente o ano com '20' após o mês ser completado, mas apenas se isDataNascimento for false
    if (newText.length == 5 &&
        newText.substring(3, 5) != '/' &&
        !isDataNascimento) {
      if (!newText.contains('20')) {
        newText = '${newText}20';
      }
    }

    // Permite edição dos dois últimos dígitos do ano após a inserção do '20'
    if (newText.length > 7 && newText.substring(5, 7) == '20') {
      if (newText.length == 8) {
        newText = oldValue.text;
      }
    }

    newText = _applyDateMask(newText);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _applyDateMask(String text) {
    String result = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (result.length > 2) {
      result = result.substring(0, 2) + result.substring(2); // Dia/Mês
    }

    if (result.length > 5) {
      result = result.substring(0, 5) + result.substring(5); // Dia/Mês/Ano
    }

    return result;
  }
}
