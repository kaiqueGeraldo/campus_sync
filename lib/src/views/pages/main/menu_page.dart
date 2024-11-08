import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/main/menu/entidade_page.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'titulo': 'Faculdades',
      'endpoint': 'Faculdades',
      'icon': Icons.cast_for_education,
    },
    {
      'titulo': 'Cursos',
      'endpoint': 'Cursos',
      'icon': Icons.co_present_outlined,
    },
    {
      'titulo': 'Disciplinas',
      'endpoint': 'Disciplinas',
      'icon': Icons.library_books_outlined,
    },
    {
      'titulo': 'Matriculas',
      'endpoint': 'Matriculas',
      'icon': Icons.assessment_outlined,
    },
    {
      'titulo': 'Turmas',
      'endpoint': 'Turmas',
      'icon': Icons.people_outline,
    },
    {
      'titulo': 'Presença',
      'endpoint': 'Users',
      'icon': Icons.route_outlined,
    },
    {
      'titulo': 'Estudantes',
      'endpoint': 'Estudantes',
      'icon': Icons.person_outline,
    },
    {
      'titulo': 'Professores',
      'endpoint': 'Professores',
      'icon': Icons.theater_comedy_outlined,
    },
    {
      'titulo': 'Funcionarios',
      'endpoint': 'Funcionarios',
      'icon': Icons.spatial_audio_off_outlined,
    },
    {
      'titulo': 'Configurações',
      'endpoint': 'Universidades',
      'icon': Icons.settings_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      body: GridView.builder(
        padding: const EdgeInsetsDirectional.all(15),
        itemCount: menuItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (context, index) {
          return buildMenuItem(
            menuItems[index]['titulo'],
            menuItems[index]['endpoint'],
            menuItems[index]['icon'],
          );
        },
      ),
    );
  }

  Widget buildMenuItem(String titulo, String endpoint, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntidadePage(
              titulo: titulo,
              endpoint: endpoint,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.lightGreyColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.backgroundBlueColor,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.backgroundBlueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
