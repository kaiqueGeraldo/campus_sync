import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/entidade_page.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  final ValueNotifier<Map<String, int?>> itemCountsNotifier;
  const MenuPage({super.key, required this.itemCountsNotifier});

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'titulo': 'Faculdades',
      'endpoint': 'Faculdade',
      'icon': Icons.cast_for_education,
    },
    {
      'titulo': 'Cursos',
      'endpoint': 'Curso',
      'icon': Icons.co_present_outlined,
    },
    {
      'titulo': 'Estudantes',
      'endpoint': 'Estudante',
      'icon': Icons.person_outline,
    },
    {
      'titulo': 'Colaboradores',
      'endpoint': 'Colaborador',
      'icon': Icons.spatial_audio_off_outlined,
    },
    {
      'titulo': 'Configurações',
      'endpoint': 'Configuracoes',
      'icon': Icons.settings_outlined,
    },
  ];

  bool isCursosDisabled = false;
  bool isEstudantesDisabled = false;
  bool isColaboradoresDisabled = false;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<bool> fetchCounts() async {
    int faculdadesCount = await ApiService().fetchItemCount('Faculdade');
    int cursosCount = await ApiService().fetchItemCount('Curso');

    bool hasChanges = false;

    if (!mounted) return hasChanges;

    setState(() {
      if (isCursosDisabled != (faculdadesCount == 0)) {
        isCursosDisabled = faculdadesCount == 0;
        hasChanges = true;
      }

      if (isEstudantesDisabled != (cursosCount == 0)) {
        isEstudantesDisabled = cursosCount == 0;
        hasChanges = true;
      }

      if (isColaboradoresDisabled != (cursosCount == 0)) {
        isColaboradoresDisabled = cursosCount == 0;
        hasChanges = true;
      }
    });

    return hasChanges;
  }

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
                isFullWidth: true, height: 140, isDisabled: false),
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
                  bool isDisabled = false;
                  if (index == 0) isDisabled = isCursosDisabled;
                  if (index == 1) isDisabled = isEstudantesDisabled;
                  if (index == 2) isDisabled = isColaboradoresDisabled;

                  return buildMenuItem(
                    menuItems[index + 1]['titulo'],
                    menuItems[index + 1]['endpoint'],
                    menuItems[index + 1]['icon'],
                    isDisabled: isDisabled,
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
    required bool isDisabled,
  }) {
    return GestureDetector(
      onTap: isDisabled
          ? () {
              String itemClicado = '';
              if (endpoint == 'Curso') {
                itemClicado = 'uma Faculdade';
              } else {
                itemClicado = 'um Curso';
              }
              String message =
                  'Para acessar esse campo primeiro você precisa cadastar $itemClicado! Se ja fez isso, por favor, clique no botão de refresh.';
              return CustomSnackbar.show(context, message);
            }
          : () {
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
          color: isDisabled
              ? AppColors.lightGreyColor.withOpacity(0.5)
              : AppColors.lightGreyColor,
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
              color: isDisabled
                  ? AppColors.backgroundBlueColor.withOpacity(0.5)
                  : AppColors.backgroundBlueColor,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDisabled
                    ? AppColors.backgroundBlueColor.withOpacity(0.5)
                    : AppColors.backgroundBlueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
