import 'package:campus_sync/route_generate.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:campus_sync/src/models/user.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialController {
  final BuildContext context;

  InitialController({required this.context});

  Future<User> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loggedUserCpf = prefs.getString('userCpf');

    if (loggedUserCpf == null) {
      throw Exception('CPF do usuário logado não encontrado');
    }

    return await ApiService().fetchUserData(loggedUserCpf);
  }

  Future<void> logout() async {
    customShowDialog(
      context: context,
      title: 'Sair da conta',
      content: 'Tem certeza que deseja sair desta conta?',
      cancelText: 'Não',
      onCancel: () => Navigator.pop(context),
      confirmText: 'Sim',
      onConfirm: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteGenerate.routeSignIn,
          (route) => false,
        );

        CustomSnackbar.show(
          context,
          'Logout realizado com sucesso!',
          backgroundColor: AppColors.greyColor,
        );
      },
    );
  }
}
