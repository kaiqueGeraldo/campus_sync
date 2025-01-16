import 'dart:async';
import 'dart:convert';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExcluirItensPage extends StatefulWidget {
  final String tipoItem;

  const ExcluirItensPage({super.key, required this.tipoItem});

  @override
  State<ExcluirItensPage> createState() => _ExcluirItensPageState();
}

class _ExcluirItensPageState extends State<ExcluirItensPage> {
  late Future<List<Map<String, dynamic>>> itensFuture;
  List<Map<String, dynamic>> itensExibidos = [];
  late CadastroController controller;
  final GlobalKey<FormState> itemFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isDadosExpanded = true;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    itensFuture = buscarItensInicial();

    controller.cursoSelecionadoNotifier.addListener(() {
      final cursoId = controller.cursoSelecionadoNotifier.value;
      if (cursoId != null) {
        setState(() {
          itensFuture = buscarItens(cursoId, widget.tipoItem);
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> buscarItensInicial() async {
    final itens = await buscarItens(1, widget.tipoItem);
    itensExibidos = List.from(itens);
    return itensExibidos;
  }

  Future<List<Map<String, dynamic>>> buscarItens(
      int cursoId, String tipoItem) async {
    try {
      final cursoResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/Curso/$cursoId'),
      );

      if (cursoResponse.statusCode != 200) {
        throw Exception('Erro ao buscar o curso.');
      }

      final cursoData = jsonDecode(cursoResponse.body) as Map<String, dynamic>;

      if (!cursoData.containsKey('${tipoItem.toLowerCase()}s')) {
        throw Exception('Itens do tipo $tipoItem não encontrados.');
      }

      return (cursoData['${tipoItem.toLowerCase()}s'] as List)
          .cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Erro ao buscar itens: $error');
    }
  }

  Future<void> deletarItem(int cursoId, Map<String, dynamic> item) async {
    setState(() {
      _isLoading = true;
    });

    final itemId = item['id'];
    bool desfazerClicado = false;

    final itemIndex = itensExibidos.indexWhere((e) => e['id'] == itemId);

    if (itemIndex == -1) {
      CustomSnackbar.show(
        context,
        'Item não encontrado na lista.',
      );
      return;
    }

    final itemRemovido = itensExibidos.removeAt(itemIndex);
    setState(() {});

    CustomSnackbar.show(
      context,
      '${item['nome']} foi excluído.',
      duration: const Duration(seconds: 3),
      actionLabel: 'Desfazer',
      textColor: AppColors.textColor,
      showCloseButton: false,
      onAction: () {
        desfazerClicado = true;

        itensExibidos.insert(itemIndex, itemRemovido);
        setState(() {});

        CustomSnackbar.show(
          context,
          '${item['nome']} foi restaurado com sucesso!',
          backgroundColor: AppColors.successColor,
        );

        setState(() {
          _isLoading = false;
        });
      },
    );

    Timer(
      const Duration(seconds: 4),
      () async {
        if (!desfazerClicado) {
          try {
            setState(() {
              _isLoading = true;
            });
            final response = await http.delete(
              Uri.parse(
                  '${ApiService.baseUrl}/Curso/$cursoId/excluir-${widget.tipoItem.toLowerCase()}/$itemId'),
            );

            if (response.statusCode != 200) {
              throw Exception('Erro ao deletar item no backend.');
            }

            CustomSnackbar.show(
              context,
              '${item['nome']} foi excluído permanentemente.',
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            );
          } catch (error) {
            itensExibidos.insert(itemIndex, itemRemovido);
            setState(() {});

            customShowDialog(
              context: context,
              title: 'Erro',
              content:
                  'Não foi possível excluir o item no backend. Erro: $error',
              confirmText: 'Fechar',
              onConfirm: () => Navigator.pop(context),
            );
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.buttonColor,
          ),
        ),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () {}, isLoading: false);
    }

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) {
          print('Navegação permitida.');
        } else {
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(
              backgroundColor: AppColors.errorColor,
              content: const Text(
                'Navegação bloqueada',
                style: TextStyle(color: AppColors.textColor),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                  child: const Text(
                    'FECHAR',
                    style: TextStyle(color: AppColors.textColor),
                  ),
                ),
              ],
            ),
          );

          Timer(const Duration(seconds: 3), () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          });
          print('Tentativa de navegação bloqueada.');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        appBar: AppBar(
          title: Text('Excluir ${widget.tipoItem}'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                CustomExpansionCard(
                  formKey: itemFormKey,
                  title: 'Excluir ${widget.tipoItem}s',
                  icon: Icons.library_books,
                  initiallyExpanded: true,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDadosExpanded = expanded;
                    });
                  },
                  children: [
                    controller.buildFaculdadeInput(context),
                    ValueListenableBuilder<Map>(
                      valueListenable: controller.faculdadeSelecionadaNotifier,
                      builder: (context, faculdadeSelecionada, child) {
                        if (faculdadeSelecionada.isNotEmpty) {
                          return controller.buildCursosDropdown(
                              context, !_isLoading);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    ValueListenableBuilder<int?>(
                      valueListenable: controller.cursoSelecionadoNotifier,
                      builder: (context, cursoSelecionado, child) {
                        if (cursoSelecionado != null) {
                          return FutureBuilder<List<Map<String, dynamic>>>(
                            future: itensFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.buttonColor,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text(
                                  'Erro ao carregar ${widget.tipoItem}: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                );
                              }

                              itensExibidos = snapshot.data ?? [];

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: itensExibidos.length,
                                itemBuilder: (context, index) {
                                  final item = itensExibidos[index];
                                  return Card(
                                    color: AppColors.backgroundWhiteColor,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      // leading: CircleAvatar(
                                      //   backgroundColor: AppColors.buttonColor,
                                      //   child: Text(
                                      //     item['nome']
                                      //             ?.substring(0, 1)
                                      //             .toUpperCase() ??
                                      //         '?',
                                      //     style: const TextStyle(
                                      //       color: Colors.white,
                                      //       fontWeight: FontWeight.bold,
                                      //     ),
                                      //   ),
                                      // ),
                                      title: Text(
                                        item['nome'] ?? 'Item ${index + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      subtitle: widget.tipoItem == 'Turma'
                                          ? Text(
                                              item['periodoString'],
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.darkGreyColor,
                                              ),
                                            )
                                          : null,
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          await customShowDialog(
                                            context: context,
                                            title: 'Confirmar Exclusão',
                                            content:
                                                'Tem certeza que deseja excluir ${item['nome']}?',
                                            cancelText: 'Cancelar',
                                            onCancel: () =>
                                                Navigator.of(context).pop(),
                                            confirmText: 'Excluir',
                                            onConfirm: () async {
                                              Navigator.of(context).pop();
                                              await deletarItem(
                                                  cursoSelecionado, item);
                                            },
                                          );
                                        },
                                      ),
                                      onTap: () {
                                        CustomSnackbar.show(
                                          context,
                                          '${item['nome']}',
                                          backgroundColor:
                                              AppColors.backgroundBlueColor,
                                          duration: const Duration(seconds: 3),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
