import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/detalhes_item_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/editar/editar_item_page.dart';
import 'package:flutter/material.dart';

class EntidadeConfiguracoesController with ChangeNotifier {
  final String endpoint;
  List<Map<String, dynamic>> itens = [];
  List<Map<String, dynamic>> itensFiltrados = [];
  bool isLoading = true;

  EntidadeConfiguracoesController(this.endpoint);

  Future<void> carregarItens() async {
    try {
      itens = await ApiService().carregarItens(endpoint);
      itensFiltrados = List.from(itens);
    } catch (e) {
      print('Erro ao carregar itens: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filtrarItens(String query) {
    query = query.toLowerCase();
    if (query.isEmpty) {
      itensFiltrados = [];
    } else {
      itensFiltrados = itens.where((item) {
        final nome = item['nome']?.toLowerCase() ?? '';
        return nome.contains(query);
      }).toList();
    }
    print('Itens depois do filtro: ${itensFiltrados.length}');
    notifyListeners();
  }

  void confirmarExcluir(BuildContext context, Map<String, dynamic> item) {
    customShowDialog(
      context: context,
      title: 'Excluir ${item['nome']}',
      content:
          'Tem certeza que deseja excluir ${item['nome']}? Todos os itens relacionados também serão excluídos.',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      onConfirm: () {
        Navigator.pop(context);
        _excluirItem(context, item);
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  void _excluirItem(BuildContext context, Map<String, dynamic> item) async {
    final itemIndex = itens.indexOf(item);
    bool desfazerClicado = false;

    itens.remove(item);
    itensFiltrados.remove(item);
    notifyListeners();

    CustomSnackbar.show(
      context,
      '${item['nome']} foi excluído.',
      duration: const Duration(seconds: 3),
      actionLabel: 'Desfazer',
      textColor: AppColors.textColor,
      showCloseButton: false,
      onAction: () async {
        desfazerClicado = true;

        itens.insert(itemIndex.clamp(0, itens.length), item);
        itensFiltrados.insert(itemIndex.clamp(0, itensFiltrados.length), item);
        notifyListeners();
        CustomSnackbar.show(
          context,
          '${item['nome']} foi restaurado com sucesso!',
          backgroundColor: AppColors.successColor,
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (!desfazerClicado) {
      try {
        await ApiService()
            .excluirDadosConfiguracoes(endpoint, item['id'].toString());
      } catch (e) {
        itens.insert(itemIndex, item);
        itensFiltrados.insert(itemIndex, item);
        notifyListeners();
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

  void editarItem(
      BuildContext context, Map<String, dynamic> item, String endpoint) {
    print('ITEM: $item');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarItemPage(
          item: item,
          onSave: (Map<String, dynamic> atualizado) {
            final index = itens.indexWhere((i) => i['id'] == item['id']);
            if (index != -1) {
              itens[index] = atualizado;
              filtrarItens('');
              notifyListeners();
            }
            Navigator.pop(context);
          },
          titulo: endpoint,
          endpoint: endpoint,
        ),
      ),
    );
  }

  void verDetalhes(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesItemPage(
          id: id,
          endpoint: endpoint,
        ),
      ),
    );
  }
}
