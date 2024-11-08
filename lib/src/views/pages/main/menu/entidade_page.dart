import 'package:campus_sync/src/controllers/main/menu/entidade_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/listagem_page.dart';
import 'package:flutter/material.dart';

class EntidadePage extends StatelessWidget {
  final String titulo;
  final String endpoint;
  late final EntidadeController _controller;

  EntidadePage({super.key, required this.titulo, required this.endpoint}) {
    _controller = EntidadeController(endpoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.navigateToCadastroPage(
                  context,
                  CadastroPage(
                    endpoint: endpoint,
                    initialData: _controller.initialData,
                  ),
                ),
                child: _buildOptionContainer(
                  icon: Icons.add,
                  label: 'Cadastrar',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.navigateToListagemPage(
                  context,
                  ListagemPage(
                    endpoint: endpoint,
                    fieldMapping: _controller.fieldMapping,
                  ),
                ),
                child: _buildOptionContainer(
                  icon: Icons.format_list_bulleted_outlined,
                  label: 'Listar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionContainer(
      {required IconData icon, required String label}) {
    return Container(
      height: 120,
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
          Icon(icon, color: AppColors.backgroundBlueColor, size: 50),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.backgroundBlueColor,
            ),
          ),
        ],
      ),
    );
  }
}
