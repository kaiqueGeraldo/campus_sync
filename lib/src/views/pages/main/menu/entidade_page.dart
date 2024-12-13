import 'package:campus_sync/src/controllers/main/menu/entidade_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_colaborador_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_curso_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_estudante_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_faculdade_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/atualizar_dados_universidade_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/atualizar_foto_universidade_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/entidade_configuracoes_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/listagem_page.dart';
import 'package:flutter/material.dart';

class EntidadePage extends StatelessWidget {
  final String titulo;
  final String endpoint;
  late final EntidadeController _controller;

  EntidadePage({
    super.key,
    required this.titulo,
    required this.endpoint,
  }) {
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
            child: Stack(
              children: [
                if (endpoint == 'Configuracoes')
                  Column(
                    children: [
                      ...drawerMenuItems
                          .where((item) => item.endpoint != 'Configuracoes')
                          .map(
                            (item) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: AppColors.lightGreyColor,
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(item.icon),
                                title: Text(item.title),
                                onTap: () async {
                                  if (item.endpoint == 'Universidade') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EntidadePage(
                                          titulo: 'Configurar Universidade',
                                          endpoint: 'Universidade',
                                        ),
                                      ),
                                    );
                                  } else {
                                    List<Map<String, dynamic>> itens =
                                        await _controller
                                            .carregarItens(item.endpoint);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EntidadeConfiguracoesPage(
                                          itens: itens,
                                          titulo: item.title,
                                          onEditar: (item) {},
                                          onExcluir: (item) {},
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _controller.navigateToCadastroPage(
                              context,
                              _getCadastroPage(context),
                            );
                          },
                          child: _buildOptionContainer(
                            icon: endpoint == 'Universidade'
                                ? Icons.account_box_outlined
                                : Icons.add,
                            label: endpoint == 'Universidade'
                                ? 'Dados da Empresa'
                                : 'Cadastrar',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (endpoint != 'Universidade') {
                              _controller.navigateToListagemPage(
                                context,
                                ListagemPage(
                                  endpoint: endpoint,
                                  fieldMapping: _controller.fieldMapping,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AtualizarFotoUniversidadePage(),
                                ),
                              );
                            }
                          },
                          child: _buildOptionContainer(
                            icon: endpoint == 'Universidade'
                                ? Icons.photo_outlined
                                : Icons.format_list_bulleted_outlined,
                            label: endpoint == 'Universidade'
                                ? 'Logo da Empresa'
                                : 'Listar',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getCadastroPage(BuildContext context) {
    switch (endpoint) {
      case 'Faculdade':
        return CadastroFaculdadePage(
          endpoint: endpoint,

        );
      case 'Estudante':
        return CadastroEstudantePage(
          endpoint: endpoint,

        );
      case 'Colaborador':
        return CadastroColaboradorPage(
          endpoint: endpoint,

        );
      case 'Curso':
        return CadastroCursoPage(
          endpoint: endpoint,

        );
      case 'Universidade':
        return AtualizarDadosUniversidadePage(
          endpoint: endpoint,

        );
      default:
        return const CadastroPage(
          endpoint: 'default',
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
