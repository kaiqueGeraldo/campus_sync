import 'package:flutter/material.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InitialController {
  final BuildContext context;

  InitialController({required this.context});

  Future<User> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loggedUserCpf = prefs.getString('userCpf');

    if (loggedUserCpf == null) {
      throw Exception('CPF do usuário logado não encontrado');
    }

    final response = await http.get(
      Uri.parse(
          'https://campussyncapi-cvgwgqawd2etfqfa.canadacentral-01.azurewebsites.net/api/Users/$loggedUserCpf'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        return User.fromJson(jsonDecode(response.body));
      } catch (e) {
        throw Exception('Erro ao decodificar os dados do usuário: $e');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Usuário não encontrado');
    } else {
      throw Exception(
          'Erro ao carregar dados do usuário: ${response.reasonPhrase}');
    }
  }

  Future<void> logout() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text('Sair da conta'),
          content: const Text('Tem certeza que deseja sair desta conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Não',
                style: TextStyle(
                  color: AppColors.buttonColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('userCpf');
                await prefs.remove('userNome');
                await prefs.remove('userEmail');
                await prefs.remove('userPassword');
                await prefs.remove('userToken');

                Navigator.pushNamedAndRemoveUntil(
                    context, '/signin', (Route<dynamic> route) => false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout realizado com sucesso!'),
                  ),
                );
              },
              child: const Text(
                'Sim',
                style: TextStyle(
                  color: AppColors.buttonColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
