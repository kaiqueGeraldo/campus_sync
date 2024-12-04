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
      'titulo': 'Estudantes',
      'endpoint': 'Estudantes',
      'icon': Icons.person_outline,
    },
    {
      'titulo': 'Colaboradores',
      'endpoint': 'Colaboradores',
      'icon': Icons.spatial_audio_off_outlined,
    },
    {
      'titulo': 'Configurações',
      'endpoint': 'Config',
      'icon': Icons.settings_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      body: Padding(
        padding: const EdgeInsetsDirectional.all(15),
        child: Column(
          children: [
            buildMenuItem(menuItems[0]['titulo'], menuItems[0]['endpoint'],
                menuItems[0]['icon'],
                isFullWidth: true, height: 140),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: menuItems.length - 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  return buildMenuItem(
                    menuItems[index + 1]['titulo'],
                    menuItems[index + 1]['endpoint'],
                    menuItems[index + 1]['icon'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(
    String titulo,
    String endpoint,
    IconData icon, {
    bool isFullWidth = false,
    double? height,
  }) {
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
        width: isFullWidth ? double.infinity : null,
        height: height ?? (isFullWidth ? height : null),
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
