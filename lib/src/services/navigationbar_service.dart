import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NavigationBarService extends ChangeNotifier {
  Color _navigationBarColor = AppColors.navigationBarColor; // Cor padrão
  Brightness _iconBrightness = Brightness.light; // Brilho dos ícones padrão

  Color get navigationBarColor => _navigationBarColor;
  Brightness get iconBrightness => _iconBrightness;

  // Método para atualizar a cor da barra de navegação
  void updateNavigationBarColor(
      {required Color color, required Brightness iconBrightness}) {
    _navigationBarColor = color;
    _iconBrightness = iconBrightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: _navigationBarColor,
      systemNavigationBarIconBrightness: _iconBrightness,
    ));
    notifyListeners();
  }
}
