import 'dart:convert';
import 'package:campus_sync/src/services/auth_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInController {
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  SignInController({required this.context});

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final response = await AuthService()
          .login(emailController.text, passwordController.text);
      await _handleResponse(response);
    } catch (e) {
      CustomSnackbar.show(context, 'Erro ao realizar login: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleResponse(response) async {
    if (response.statusCode == 200) {
      var usuarioEncontrado = json.decode(response.body);
      await _saveUserData(usuarioEncontrado);
      _showSuccessDialog(usuarioEncontrado['nome'], usuarioEncontrado['cpf'],
          usuarioEncontrado['universidadeId']);
    } else if (response.statusCode == 404) {
      _showAccountNotFoundDialog();
    } else {
      CustomSnackbar.show(context, 'Dados inválidos. Tente Novamente!');
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
      title: 'Sucesso no Login!',
      content:
          'Bem-vindo de volta ao app $nome. Clique em Entrar para continuar.',
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

  void _showAccountNotFoundDialog() {
    customShowDialog(
      context: context,
      title: 'Conta não encontrada',
      content:
          'A conta com este email não foi encontrada. Deseja criar uma nova conta?',
      confirmText: 'Criar Conta',
      cancelText: 'Cancelar',
      onConfirm: () {
        Navigator.of(context).pushNamed('/signup');
      },
    );
  }

  void navigateToForgotPassword() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForgotPasswordPage(),
        ));
  }

  void navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }
}
