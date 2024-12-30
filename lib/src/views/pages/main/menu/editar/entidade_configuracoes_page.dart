import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/editar/entidade_configuracoes_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/components/editar/custom_item_card.dart';
import 'package:campus_sync/src/views/pages/main/menu/detalhes_item_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/editar_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntidadeConfiguracoesPage extends StatefulWidget {
  final String endpoint;
  final void Function(Map<String, dynamic>) onEditar;
  final void Function(Map<String, dynamic>) onExcluir;

  const EntidadeConfiguracoesPage({
    super.key,
    required this.endpoint,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  State<EntidadeConfiguracoesPage> createState() =>
      _EntidadeConfiguracoesPageState();
}

class _EntidadeConfiguracoesPageState extends State<EntidadeConfiguracoesPage> {
  late List<Map<String, dynamic>> itensFiltrados;
  final TextEditingController pesquisaController = TextEditingController();
  final Map<String, dynamic> turmasRecuperadas = {};
  final List<Map<String, dynamic>> disciplinasRecuperadas = [];
  bool isLoading = true;

  @override
  void dispose() {
    pesquisaController.dispose();
    itensFiltrados = [];
    EntidadeConfiguracoesController(widget.endpoint).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.buttonColor),
        ),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () {}, isLoading: false);
    }

    return ChangeNotifierProvider(
      create: (_) =>
          EntidadeConfiguracoesController(widget.endpoint)..carregarItens(),
      child: Consumer<EntidadeConfiguracoesController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.isLoading,
            onPopInvokedWithResult: (bool didPop, result) {
              if (didPop) {
                print('Navegação permitida.');
              } else {
                CustomSnackbar.show(
                  context,
                  'Navegação bloqueada! Aguarde o carregamento.',
                  duration: const Duration(seconds: 2),
                );
                print('Tentativa de navegação bloqueada.');
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.backgroundWhiteColor,
              appBar: AppBar(
                title: Text('Configurar ${widget.endpoint}s'),
              ),
              body: controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.buttonColor),
                    )
                  : Column(
                      children: [
                        _buildSearchBar(controller),
                        Consumer<EntidadeConfiguracoesController>(
                          builder: (context, controller, child) {
                            return Expanded(
                              child: pesquisaController.text.isNotEmpty
                                  ? ListView.builder(
                                      itemCount:
                                          controller.itensFiltrados.length,
                                      itemBuilder: (context, index) {
                                        final item =
                                            controller.itensFiltrados[index];
                                        final id = item['id'].toString();
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: ItemCard(
                                            item: item,
                                            onDelete: () =>
                                                controller.confirmarExcluir(
                                              context,
                                              item,
                                            ),
                                            onEdit: () => controller.editarItem(
                                              context,
                                              item,
                                              widget.endpoint,
                                            ),
                                            onViewDetails: () =>
                                                controller.verDetalhes(
                                              context,
                                              id,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        'Nenhum item encontrado. Pesquise para listar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            );
                          },
                        )
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(EntidadeConfiguracoesController controller) {
    return Container(
      color: AppColors.backgroundBlueColor,
      padding: const EdgeInsets.all(12),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: pesquisaController,
        cursorColor: AppColors.backgroundBlueColor,
        maxLength: 30,
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Pesquisar',
          hintStyle: const TextStyle(color: AppColors.darkGreyColor),
          filled: true,
          fillColor: AppColors.backgroundWhiteColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search, color: AppColors.darkGreyColor),
            onPressed: () => controller.filtrarItens(pesquisaController.text),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.cancel, color: AppColors.darkGreyColor),
            onPressed: () {
              pesquisaController.clear();
              controller.filtrarItens('');
            },
          ),
        ),
        onSubmitted: controller.filtrarItens,
      ),
    );
  }
}
