import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/editar_item_page.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    itensFiltrados = [];
  }

  void _filtrarItens() {
    final query = pesquisaController.text.toLowerCase();
    setState(() {
      itensFiltrados = widget.itens.where((item) {
        final nome =
            item['nome']?.toLowerCase() ?? ''; // Verifica se 'nome' é null
        final id = item['id']?.toString() ?? ''; // Verifica se 'id' é null
        return nome.contains(query) || id.contains(query);
      }).toList();
    });
  }

  Future _verDetalhes(String endpoint, String id) async {
    try {
      final Map<String, dynamic> dados =
          await ApiService().listarDadosConfiguracoes('$endpoint/$id');

      String content;

      if (endpoint == 'Faculdades') {
        content = '''
Nome: ${dados['nome']}
Tipo: ${dados['tipoString']}
Universidade: ${dados['universidadeNome']}
Endereço:
Rua: ${dados['endereco']['rua']}
Cidade: ${dados['endereco']['cidade']}
Estado: ${dados['endereco']['estado']}
CEP: ${dados['endereco']['cep']}
''';
      } else if (endpoint == 'Cursos') {
        content = '''
Descrição: ${dados['descricao']}
Faculdade: ${dados['faculdadeNome']}
''';
      } else if (endpoint == 'Estudantes') {
        content = '''
Nome: ${dados['nome']}
Email: ${dados['email']}
Telefone: ${dados['telefone']}
Endereço:
Rua: ${dados['endereco']['rua']}
Cidade: ${dados['endereco']['cidade']}
Estado: ${dados['endereco']['estado']}
CEP: ${dados['endereco']['cep']}
''';
      } else {
        content = 'Detalhes não disponíveis para este item.';
      }

      customShowDialog(
        context: context,
        title: 'Detalhes ${widget.titulo}',
        content: content,
        confirmText: 'Fechar',
        onConfirm: () => Navigator.pop(context),
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
      content: 'Tem certeza que deseja excluir ${item['nome']}?',
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

    try {
      await ApiService()
          .excluirDadosConfiguracoes(widget.titulo, item['id'].toString());

      setState(() {
        widget.itens.remove(item);
        itensFiltrados.remove(item);
      });

      CustomSnackbar.show(
        context,
        '${item['nome']} foi excluído.',
        actionLabel: 'Desfazer',
        onAction: () async {
          try {
            await ApiService().recriarDadosConfiguracoes(widget.titulo, item);

            setState(() {
              widget.itens.insert(itemIndex, item);
              _filtrarItens();
            });
          } catch (e) {
            customShowDialog(
              context: context,
              title: 'Erro',
              content: 'Não foi possível desfazer a exclusão. Erro: $e',
              confirmText: 'Fechar',
              onConfirm: () => Navigator.pop(context),
            );
          }
        },
      );
    } catch (e) {
      customShowDialog(
        context: context,
        title: 'Erro',
        content: 'Não foi possível excluir o item. Erro: $e',
        confirmText: 'Fechar',
        onConfirm: () => Navigator.pop(context),
      );
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Configurar ${widget.titulo}'),
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
                              subtitle: Text('ID: ${item['id']}'),
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
                                    widget.itens[index]['id'].toString();
                                _verDetalhes(widget.titulo, id);
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
                    child:
                        Text('Nenhum item encontrado. Pesquise para listar.'),
                  ),
          ),
        ],
      ),
    );
  }
}
