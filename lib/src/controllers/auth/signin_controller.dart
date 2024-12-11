import 'dart:convert';
import 'package:campus_sync/src/routes/route_generate.dart';
import 'package:campus_sync/src/services/auth_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

final formKeySignIn = GlobalKey<FormState>();

class SignInController {
  final BuildContext context;
  final formKey = formKeySignIn;
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
          usuarioEncontrado['universidadeId'].toString());
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
    await prefs.setString('userImagem', usuario['urlImagem']);
    await prefs.setString('userTelefone', usuario['telefone']);
    await prefs.setString('userUniversidadeNome', usuario['universidadeNome']);
    await prefs.setString('userUniversidadeCNPJ', usuario['universidadeCNPJ']);
    await prefs.setString('userUniversidadeContatoInfo', usuario['universidadeContatoInfo']);
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

  void _showAccountNotFoundDialog() {
    customShowDialog(
      context: context,
      title: 'Conta não encontrada',
      content:
          'A conta com este email não foi encontrada. Deseja criar uma nova conta?',
      confirmText: 'Criar Conta',
      cancelText: 'Cancelar',
      onConfirm: () {
        Navigator.of(context).pushNamed(RouteGenerate.routeSignUp);
      },
    );
  }

  void navigateToForgotPassword() {
    Navigator.pushNamed(context, RouteGenerate.routeForgotPassword);
  }

  void navigateToSignUp() {
    Navigator.pushNamed(context, RouteGenerate.routeSignUp);
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscurePassword.dispose();
    isLoading.dispose();
  }
}
