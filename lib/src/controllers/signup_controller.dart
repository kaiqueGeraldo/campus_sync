import 'dart:convert';
import 'package:campus_sync/src/services/auth_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController {
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  SignUpController({required this.context});

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final response = await AuthService().register(
        cpfController.text,
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
    if (response.statusCode == 201) {
      var usuarioRegistrado = json.decode(response.body);
      await _saveUserData(usuarioRegistrado);
      _showSuccessDialog(usuarioRegistrado['nome'], usuarioRegistrado['cpf'],
          usuarioRegistrado['universidadeId']);
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
          '/initial',
          (Route<dynamic> route) => false,
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
}
