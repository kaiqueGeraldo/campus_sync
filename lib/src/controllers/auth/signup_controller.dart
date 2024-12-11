import 'dart:convert';
import 'package:campus_sync/src/routes/route_generate.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/services/auth_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:shared_preferences/shared_preferences.dart';

final formKeySignUp = GlobalKey<FormState>();

class SignUpController {
  final BuildContext context;
  final formKey = formKeySignUp;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController cpfController = MaskedTextController(mask: '000.000.000-00');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isCpfValid = ValueNotifier(false);
  final ValueNotifier<bool> isEmailValid = ValueNotifier(false);

  SignUpController({required this.context});

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final cleanCpf = cpfController.text.replaceAll('.', '').replaceAll('-', '');

    try {
      final response = await AuthService().register(
        cleanCpf,
        usernameController.text,
        emailController.text,
        passwordController.text,
      );
      await _handleResponse(response);
    } catch (e) {
      CustomSnackbar.show(context, 'Erro ao realizar cadastro: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleResponse(response) async {
    if (response.statusCode == 200) {
      var usuarioRegistrado = json.decode(response.body);
      await _saveUserData(usuarioRegistrado);
      _showSuccessDialog(usuarioRegistrado['nome'], usuarioRegistrado['cpf']);
    } else if (await ApiService().checkCpfExists(cpfController.text) &&
        await ApiService().checkEmailExists(emailController.text)) {
      customShowDialog(
        context: context,
        title: 'Conta já registrada!',
        content:
            'Já existe uma conta com esses dados regitrada no nosso app! Deseja ir para o login?',
        cancelText: 'Não',
        onCancel: () => Navigator.pop(context),
        confirmText: 'Sim',
        onConfirm: () {
          Navigator.popUntil(context, (route) => false);
        },
      );
    } else if (await ApiService().checkCpfExists(cpfController.text)) {
      CustomSnackbar.show(context, 'CPF já registrado! Tente novamente.');
    } else if (await ApiService().checkEmailExists(emailController.text)) {
      CustomSnackbar.show(context, 'Email já registrado! Tente novamente.');
    } else {
      CustomSnackbar.show(
          context, 'Erro ao registrar. Verifique os dados e tente novamente.');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userCpf', usuario['cpf'].toString());
    await prefs.setString('userNome', usuario['nome']);
    await prefs.setString('userEmail', usuario['email']);
    await prefs.setString('userToken', usuario['token']);
    await prefs.setString('userImagem', usuario['urlImagem']);
    await prefs.setString('userTelefone', usuario['telefone']);
    await prefs.setString('userUniversidadeNome', usuario['universidadeNome']);
    await prefs.setString('userUniversidadeCNPJ', usuario['universidadeCNPJ']);
    await prefs.setString('userUniversidadeContatoInfo', usuario['universidadeContatoInfo']);
  }

  void _showSuccessDialog(String nome, String cpf) {
    customShowDialog(
      context: context,
      title: 'Cadastro Realizado!',
      content: 'Bem-vindo ao app, $nome. Clique em Entrar para continuar.',
      confirmText: 'Entrar',
      onConfirm: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteGenerate.routeInitial,
          (route) => false,
          arguments: {
            'userCpf': cpf,
            'userNome': nome,
            'userEmail': emailController.text,
            'userImagem': '',
            'userTelefone': '',
            'userUniversidadeNome': '',
            'userUniversidadeCNPJ': '',
            'userUniversidadeContatoInfo': '',
          },
        );
      },
    );
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Username é obrigatório!';
    }
    return null;
  }

  String? validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo CPF é obrigatório';
    } else if (!validateCpfLogic(value)) {
      return 'CPF inválido';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Email é obrigatório!';
    } else if (!RegExp(
            r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|outlook\.com)$')
        .hasMatch(value)) {
      return 'Email inválido. Somente Gmail, Hotmail ou Outlook são permitidos.';
    }
    return null;
  }

  void updateCpfNotifier() {
    final text = cpfController.text;
    isCpfValid.value = text.isNotEmpty && validateCpfLogic(text);
  }

  void updateEmailNotifier() {
    final text = emailController.text;
    isEmailValid.value = text.isNotEmpty && validateEmailLogic(text);
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

  bool validateEmailLogic(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|outlook\.com)$')
        .hasMatch(value);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Password é obrigatório';
    } else if (value.length < 8) {
      return 'A senha deve conter no mínimo 8 caracteres';
    } else if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'A senha deve ter pelo menos uma letra minúscula';
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'A senha deve ter pelo menos uma letra maiúscula';
    } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'A senha deve ter pelo menos um número';
    } else if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(value)) {
      return 'A senha deve ter pelo menos um caractere especial';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    } else if (value != passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  void dispose() {
    usernameController.dispose();
    cpfController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    obscurePassword.dispose();
    obscureConfirmPassword.dispose();
    isLoading.dispose();
    isCpfValid.dispose();
    isEmailValid.dispose();
  }
}
