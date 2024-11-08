import 'dart:convert';
import 'package:campus_sync/route_generate.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/services/auth_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController {
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController cpfController =
      MaskedTextController(mask: '000.000.000-00');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  SignUpController({required this.context});

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
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
      _showSuccessDialog(usuarioRegistrado['nome'], usuarioRegistrado['cpf'],
          usuarioRegistrado['universidadeId'].toString());
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
    await prefs.setString(
        'universidadeId', usuario['universidadeId'].toString());
  }

  void _showSuccessDialog(String nome, String cpf, String universidadeId) {
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
            'universidadeId': universidadeId,
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
    } else if (!validarCpf(value)) {
      return 'CPF inválido';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Email é obrigatório!';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
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

  bool validarCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11) {
      return false;
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int digito1 = (soma * 10 % 11) % 10;

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int digito2 = (soma * 10 % 11) % 10;

    return digito1 == int.parse(cpf[9]) && digito2 == int.parse(cpf[10]);
  }
}
