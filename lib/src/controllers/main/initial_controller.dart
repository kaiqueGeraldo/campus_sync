import 'dart:convert';
import 'dart:typed_data';
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
    return await ApiService().fetchUserProfile(context);
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

  Future<Map<String, dynamic>> getUserData({Map? arguments}) async {
    final prefs = await SharedPreferences.getInstance();
    String userName;
    String userCpf;
    String userEmail;
    String? userImagem;
    Uint8List? userImageBytes;

    if (arguments != null) {
      userName = arguments['userNome'];
      userCpf = arguments['userCpf'];
      userEmail = arguments['userEmail'];
      userImagem = arguments['userImagem'];
    } else {
      userName = prefs.getString('userNome') ?? 'Usuário';
      userCpf = prefs.getString('userCpf') ?? '';
      userEmail = prefs.getString('userEmail') ?? '';
      userImagem = prefs.getString('userImagem');
    }

    if (userImagem != null && userImagem.isNotEmpty) {
      try {
        userImageBytes = base64Decode(userImagem);
      } catch (e) {
        print('Erro ao decodificar imagem Base64: $e');
        userImageBytes = null;
      }
    }

    return {
      'userName': userName,
      'userCpf': userCpf,
      'userEmail': userEmail,
      'userImageBytes': userImageBytes,
    };
  }
}
