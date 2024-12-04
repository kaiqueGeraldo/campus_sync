import 'package:campus_sync/src/controllers/main/menu/entidade_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_colaborador_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_curso_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_estudante_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_faculdade_page.dart';
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
    return FutureBuilder<void>(
      future: _controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.buttonColor),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(titulo)),
            body: Center(
              child: Text('Erro: ${snapshot.error}'),
            ),
          );
        }

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
                    onTap: () {
                      // Redireciona para o cadastro específico
                      _controller.navigateToCadastroPage(
                        context,
                        _getCadastroPage(context),
                      );
                    },
                    child: _buildOptionContainer(
                      icon: Icons.add,
                      label: 'Cadastrar',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Redireciona para a página de listagem
                      _controller.navigateToListagemPage(
                        context,
                        ListagemPage(
                          endpoint: endpoint,
                          fieldMapping: _controller.fieldMapping,
                        ),
                      );
                    },
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
      },
    );
  }

  // Função que retorna a página de cadastro de acordo com o endpoint
  Widget _getCadastroPage(BuildContext context) {
    switch (endpoint) {
      case 'Faculdades':
        return CadastroFaculdadePage(
          endpoint: endpoint,
          initialData: _controller.initialData,
        );
      case 'Estudantes':
        return CadastroEstudantePage(
          endpoint: endpoint,
          initialData: _controller.initialData,
        );
      case 'Colaboradores':
        return CadastroColaboradorPage(
          endpoint: endpoint,
          initialData: _controller.initialData,
        );
      case 'Cursos':
        return CadastroCursoPage(
          endpoint: endpoint,
          initialData: _controller.initialData,
        );
      default:
        return const CadastroPage(
          endpoint: 'default',
          initialData: {},
        );
    }
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
