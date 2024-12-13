import 'package:campus_sync/src/routes/route_generate.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialController {
  final BuildContext context;

  InitialController({required this.context});

  Future<Map<String, dynamic>> fetchUserData() async {
    return await ApiService().fetchUserProfile();
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
