import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/detalhes_item_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/editar_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntidadeConfiguracoesPage extends StatefulWidget {
  final List<Map<String, dynamic>> itens;
  final String titulo;
  final void Function(Map<String, dynamic>) onEditar;
  final void Function(Map<String, dynamic>) onExcluir;

  const EntidadeConfiguracoesPage({
    super.key,
    required this.itens,
    required this.titulo,
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

  @override
  void initState() {
    super.initState();
    itensFiltrados = [];
  }

  void _filtrarItens() {
    final query = pesquisaController.text.toLowerCase();
    setState(() {
      itensFiltrados = widget.itens.where((item) {
        final nome = item['nome']?.toLowerCase() ?? '';
        final id = item['id'].toString();
        return nome.contains(query) || id.contains(query);
      }).toList();
    });
  }

  Future<void> _verDetalhes(String endpoint, String id) async {
    print(widget.titulo);

    try {
      final Map<String, dynamic> dados =
          await ApiService().listarDadosConfiguracoes(endpoint, id);
      print('Dados retornados: $dados');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalhesItemPage(
            titulo: widget.titulo,
            dados: dados,
          ),
        ),
      );
    } catch (e) {
      customShowDialog(
        context: context,
        title: 'Erro',
        content: 'Não foi possível carregar os detalhes. Erro: $e',
        confirmText: 'Fechar',
        onConfirm: () => Navigator.pop(context),
      );
    }
  }

  void _confirmarExcluir(Map<String, dynamic> item) {
    customShowDialog(
      context: context,
      title: 'Excluir ${widget.titulo}',
      content: 'Tem certeza que deseja excluir ${item['nome']}? Todos os itens relacionados também serão excluídos.',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      onConfirm: () {
        Navigator.pop(context);
        _excluirItem(item);
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  void _excluirItem(Map<String, dynamic> item) async {
    final itemIndex = widget.itens.indexOf(item);
    bool desfazerClicado = false;

    setState(() {
      widget.itens.remove(item);
      itensFiltrados.remove(item);
    });

    CustomSnackbar.show(
      context,
      '${item['nome']} foi excluído.',
      actionLabel: 'Desfazer',
      textColor: AppColors.textColor,
      showCloseButton: false,
      onAction: () async {
        desfazerClicado = true;

        setState(() {
          widget.itens.insert(itemIndex.clamp(0, widget.itens.length), item);
          itensFiltrados.insert(
              itemIndex.clamp(0, itensFiltrados.length), item);
        });

        CustomSnackbar.show(
          context,
          '${item['nome']} foi restaurado com sucesso!',
          backgroundColor: AppColors.successColor,
        );
      },
    );
    await Future.delayed(const Duration(seconds: 6));

    if (!desfazerClicado) {
      try {
        await ApiService()
            .excluirDadosConfiguracoes(widget.titulo, item['id'].toString());
      } catch (e) {
        setState(() {
          widget.itens.insert(itemIndex, item);
          itensFiltrados.insert(itemIndex, item);
        });

        customShowDialog(
          context: context,
          title: 'Erro',
          content: 'Não foi possível excluir o item no backend. Erro: $e',
          confirmText: 'Fechar',
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }

  void _editarItem(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarItemPage(
          item: item,
          onSave: (Map<String, dynamic> atualizado) {
            setState(() {
              final index =
                  widget.itens.indexWhere((i) => i['id'] == item['id']);
              if (index != -1) {
                widget.itens[index] = atualizado;
                _filtrarItens();
              }
            });
            Navigator.pop(context);
          },
          titulo: widget.titulo,
          endpoint: widget.titulo,
        ),
      ),
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
        )),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () {}, isLoading: false);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: widget.titulo == 'Colaborador'
            ? Text('Configurar ${widget.titulo}es')
            : Text('Configurar ${widget.titulo}s'),
        backgroundColor: AppColors.backgroundBlueColor,
        shadowColor: Colors.black,
        elevation: 4,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.backgroundBlueColor,
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: pesquisaController,
              decoration: InputDecoration(
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
                  icon:
                      const Icon(Icons.search, color: AppColors.darkGreyColor),
                  onPressed: _filtrarItens,
                ),
                suffixIcon: IconButton(
                  icon:
                      const Icon(Icons.cancel, color: AppColors.darkGreyColor),
                  onPressed: () {
                    pesquisaController.clear();
                    setState(() {
                      itensFiltrados = [];
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _filtrarItens(),
            ),
          ),
          Expanded(
            child: itensFiltrados.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: itensFiltrados.length,
                    itemBuilder: (context, index) {
                      final item = itensFiltrados[index];

                      String subtitle;
                      if (widget.titulo == 'Faculdade') {
                        subtitle = '${item['universidadeNome'] ?? ''}';
                      } else if (widget.titulo == 'Curso') {
                        subtitle = '${item['faculdadeNome'] ?? ''}';
                      } else if (widget.titulo == 'Estudante' ||
                          widget.titulo == 'Colaborador') {
                        subtitle =
                            '${item['turmaNome'] ?? ''}${item['cargo'] ?? ''}';
                      } else {
                        subtitle = 'Detalhes não disponíveis';
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: AppColors.lightGreyColor,
                        elevation: 4,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                item['nome'] ?? 'Nome não identificado',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(subtitle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: AppColors.backgroundBlueColor),
                                    onPressed: () => _editarItem(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _confirmarExcluir(item),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            TextButton(
                              onPressed: () {
                                String id =
                                    itensFiltrados[index]['id'].toString();
                                _verDetalhes(widget.titulo, id);
                                print('ID: $id');
                              },
                              child: const Text(
                                'Mostrar informações completas',
                                style: TextStyle(color: AppColors.buttonColor),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Nenhum item encontrado. Pesquise para listar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
