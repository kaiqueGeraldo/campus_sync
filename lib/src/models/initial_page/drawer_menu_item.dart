import 'package:flutter/material.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String endpoint;
  const DrawerMenuItem({required this.title, required this.icon, required this.endpoint});
}

final List<DrawerMenuItem> drawerMenuItems = [
  const DrawerMenuItem(title: 'Faculdades', icon: Icons.cast_for_education_outlined, endpoint: 'Faculdade'),
  const DrawerMenuItem(title: 'Cursos', icon: Icons.co_present_outlined, endpoint: 'Curso'),
  const DrawerMenuItem(title: 'Estudantes', icon: Icons.person_outline, endpoint: 'Estudante'),
  const DrawerMenuItem(title: 'Colaboradores', icon: Icons.spatial_audio_off_outlined, endpoint: 'Colaborador'),
  const DrawerMenuItem(title: 'Configurações', icon: Icons.settings_outlined, endpoint: 'Configuracoes'),
  const DrawerMenuItem(title: 'Universidade', icon: Icons.school_outlined, endpoint: 'Universidade'),
];
