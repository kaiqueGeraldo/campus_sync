import 'package:flutter/material.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String endpoint;
  const DrawerMenuItem({required this.title, required this.icon, required this.endpoint});
}

final List<DrawerMenuItem> drawerMenuItems = [
  const DrawerMenuItem(title: 'Faculdades', icon: Icons.cast_for_education_outlined, endpoint: 'Faculdades'),
  const DrawerMenuItem(title: 'Cursos', icon: Icons.co_present_outlined, endpoint: 'Cursos'),
  const DrawerMenuItem(title: 'Disciplinas', icon: Icons.library_books_outlined, endpoint: 'Disciplinas'),
  const DrawerMenuItem(title: 'Matriculas', icon: Icons.assessment_outlined, endpoint: 'Matriculas'),
  const DrawerMenuItem(title: 'Turmas', icon: Icons.people_outline, endpoint: 'Turmas'),
  const DrawerMenuItem(title: 'Presença', icon: Icons.route_outlined, endpoint: 'Presenca'),
  const DrawerMenuItem(title: 'Estudantes', icon: Icons.person_outline, endpoint: 'Estudantes'),
  const DrawerMenuItem(title: 'Professores', icon: Icons.theater_comedy_outlined, endpoint: 'Professores'),
  const DrawerMenuItem(title: 'Funcionários', icon: Icons.spatial_audio_off_outlined, endpoint: 'Funcionarios'),
];
