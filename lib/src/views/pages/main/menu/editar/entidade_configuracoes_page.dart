import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/editar_item_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        final nome = item['nome']?.toLowerCase() ?? '';
        final id = item['id']?.toString() ?? '';
        return nome.contains(query) || id.contains(query);
      }).toList();
    });
  }

  Future<void> _verDetalhes(String endpoint, String id) async {
    try {
      final Map<String, dynamic> dados =
          await ApiService().listarDadosConfiguracoes(endpoint, id);

      List<Widget> content;

      if (endpoint == 'Faculdades') {
        content = [
          _buildDetailTile(
              'Nome', dados['nome'], Icons.cast_for_education_outlined),
          _buildDetailTile(
              'Tipo', dados['tipoString'], Icons.apartment_rounded),
          _buildDetailTile(
              'Universidade', dados['universidadeNome'], Icons.account_balance),
          const SizedBox(height: 10),
          const Text(
            'Endereço:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDetailTile(
              'Rua', dados['endereco']['rua'], Icons.straighten_outlined),
          _buildDetailTile('Cidade', dados['endereco']['cidade'],
              Icons.location_city_rounded),
          _buildDetailTile('Estado', dados['endereco']['estado'],
              Icons.store_mall_directory_outlined),
          _buildDetailTile(
              'CEP', dados['endereco']['cep'], Icons.location_on_outlined),
        ];
      } else if (endpoint == 'Cursos') {
        content = [
          _buildDetailTile('Descrição', dados['descricao'], Icons.tag_outlined),
          _buildDetailTile(
            'Mensalidade',
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(
              double.tryParse(dados['mensalidade'].toString()) ?? 0,
            ),
            Icons.attach_money_outlined,
          ),
          _buildDetailTile('Faculdade', dados['faculdadeNome'],
              Icons.cast_for_education_outlined),
        ];
      } else if (endpoint == 'Estudantes') {
        content = [
          _buildDetailTile('Nome', dados['nome'], Icons.tag_outlined),
          _buildDetailTile('Email', dados['email'], Icons.email),
          _buildDetailTile('Telefone', dados['telefone'], Icons.phone),
          const SizedBox(height: 10),
          const Text(
            'Endereço:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDetailTile(
              'Rua', dados['endereco']['rua'], Icons.straighten_outlined),
          _buildDetailTile('Cidade', dados['endereco']['cidade'],
              Icons.location_city_rounded),
          _buildDetailTile('Estado', dados['endereco']['estado'],
              Icons.store_mall_directory_outlined),
          _buildDetailTile(
              'CEP', dados['endereco']['cep'], Icons.location_on_outlined),
        ];
      } else {
        content = [const Text('Detalhes não disponíveis para este item.')];
      }

      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Detalhes ${widget.titulo}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: AppColors.buttonColor),
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildDetailTile(String title, String? value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? 'Não informado'),
    );
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
                                    itensFiltrados[index]['id'].toString();
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
