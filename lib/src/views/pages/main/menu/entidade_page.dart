import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/entidade_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/views/pages/main/initial_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_colaborador_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_curso_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_estudante_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/cadastro_faculdade_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/atualizar_dados_universidade_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/atualizar_foto_universidade_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/conta_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/entidade_configuracoes_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/listagem_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntidadePage extends StatefulWidget {
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
  State<EntidadePage> createState() => _EntidadePageState();
}

class _EntidadePageState extends State<EntidadePage> {
  Map<String, dynamic> item = {};

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: Center(
            child: CircularProgressIndicator(
          color: AppColors.buttonColor,
        )),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () {}, isLoading: false);
    }

    return FutureBuilder<void>(
      future: widget._controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.buttonColor),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.titulo)),
            body: Center(
              child: Text('Erro: ${snapshot.error}'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundWhiteColor,
          appBar: AppBar(
            title: Text(widget.titulo),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                if (widget.endpoint == 'Configuracoes')
                  Column(
                    children: [
                      ...drawerMenuItems
                          .where((item) =>
                              item.endpoint != 'Configuracoes' &&
                              item.endpoint != 'Conta')
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
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
                                          await widget._controller
                                              .carregarItens(item.endpoint);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EntidadeConfiguracoesPage(
                                            itens: itens,
                                            titulo: item.endpoint,
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
                          ),
                      if (drawerMenuItems
                          .any((item) => item.endpoint == 'Conta'))
                        Expanded(
                          child: Column(
                            children: [
                              const Spacer(),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: AppColors.lightGreyColor,
                                elevation: 4,
                                child: ListTile(
                                  leading:
                                      const Icon(Icons.account_circle_outlined),
                                  title: const Text('Conta'),
                                  onTap: () async {
                                    widget._controller.navigateToContaPage(
                                        context, const ContaPage());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget._controller.navigateToCadastroPage(
                                  context,
                                  _getCadastroPage(context),
                                );
                              },
                              child: _buildOptionContainer(
                                icon: widget.endpoint == 'Universidade'
                                    ? Icons.account_box_outlined
                                    : Icons.add,
                                label: widget.endpoint == 'Universidade'
                                    ? 'Dados da Empresa'
                                    : 'Cadastrar',
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (widget.endpoint != 'Universidade') {
                                  widget._controller.navigateToListagemPage(
                                    context,
                                    ListagemPage(
                                      endpoint: widget.endpoint,
                                      fieldMapping:
                                          widget._controller.fieldMapping,
                                      cameFromHome: false,
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
                                icon: widget.endpoint == 'Universidade'
                                    ? Icons.photo_outlined
                                    : Icons.format_list_bulleted_outlined,
                                label: widget.endpoint == 'Universidade'
                                    ? 'Logo da Empresa'
                                    : 'Listar',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (widget.endpoint == 'Faculdade' ||
                          widget.endpoint == 'Curso')
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  widget._controller.editarItemPage(
                                    context,
                                    AtualizarDadosUniversidadePage(
                                      endpoint: widget.endpoint,
                                    ),
                                  );
                                },
                                child: _buildOptionContainer(
                                  icon: Icons.edit,
                                  label: widget.endpoint == 'Faculdade'
                                      ? 'Adicionar Curso'
                                      : 'Adicionar Turmas e Discilinas',
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: Container())
                          ],
                        ),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getCadastroPage(BuildContext context) {
    switch (widget.endpoint) {
      case 'Faculdade':
        return CadastroFaculdadePage(
          endpoint: widget.endpoint,
        );
      case 'Estudante':
        return CadastroEstudantePage(
          endpoint: widget.endpoint,
        );
      case 'Colaborador':
        return CadastroColaboradorPage(
          endpoint: widget.endpoint,
        );
      case 'Curso':
        return CadastroCursoPage(
          endpoint: widget.endpoint,
        );
      case 'Universidade':
        return AtualizarDadosUniversidadePage(
          endpoint: widget.endpoint,
        );
      default:
        return const InitialPage(cameFromSignIn: false);
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
