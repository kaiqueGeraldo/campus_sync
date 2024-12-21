import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/listagem_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/pages/main/menu/detalhes_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListagemPage extends StatefulWidget {
  final String endpoint;
  final Map<String, String> fieldMapping;
  final bool cameFromHome;

  const ListagemPage({
    super.key,
    required this.endpoint,
    required this.fieldMapping,
    required this.cameFromHome,
  });

  @override
  State<ListagemPage> createState() => _ListagemPageState();
}

class _ListagemPageState extends State<ListagemPage> {
  late ListagemController _controller;
  late Future<List<dynamic>> _futureList;
  late List<dynamic> filteredItems = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ListagemController();
    _futureList = _controller.listar(widget.endpoint);
  }

  void _filterList(String query, List<dynamic> items) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredItems = items
          .where((item) => (item[widget.fieldMapping['title'] ?? 'nome'] ?? '')
              .toString()
              .toLowerCase()
              .contains(lowerQuery))
          .toList();
    });
  }

  Future<void> _verDetalhes(String endpoint, String id) async {
    print(endpoint);

    try {
      final Map<String, dynamic> dados =
          await ApiService().listarDadosConfiguracoes(endpoint, id);
      print('Dados retornados: $dados');
      print('Tipo do item: ${dados['tipo']}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalhesItemPage(
            titulo: endpoint,
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
        title: widget.cameFromHome
            ? widget.endpoint == 'Colaborador'
                ? Text('Detalhes de ${widget.endpoint}es')
                : Text('Detalhes de ${widget.endpoint}s')
            : widget.endpoint == 'Colaborador'
                ? Text('Listagem de ${widget.endpoint}es')
                : Text('Listagem de ${widget.endpoint}s'),
        backgroundColor: AppColors.backgroundBlueColor,
        shadowColor: Colors.black,
        elevation: 4,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.buttonColor,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'Nenhum item encontrado.',
              textAlign: TextAlign.center,
            ));
          }

          final items = snapshot.data!;
          if (filteredItems.isEmpty && searchController.text.isEmpty) {
            filteredItems = items;
          }

          return Column(
            children: [
              Container(
                color: AppColors.backgroundBlueColor,
                padding: const EdgeInsets.all(12),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Localizar',
                    hintStyle: const TextStyle(color: AppColors.darkGreyColor),
                    filled: true,
                    fillColor: AppColors.backgroundWhiteColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search,
                          color: AppColors.darkGreyColor),
                      onPressed: () =>
                          _filterList(searchController.text, items),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel,
                          color: AppColors.darkGreyColor),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          filteredItems = items;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) => _filterList(value, items),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    String subtitle;
                    if (widget.endpoint == 'Faculdade') {
                      subtitle =
                          'Tipo: ${item['tipoString'] ?? '-'}\nUniversidade: ${item['universidadeNome'] ?? '-'}';
                    } else if (widget.endpoint == 'Curso') {
                      subtitle =
                          'Mensalidade: R\$ ${item['mensalidade'] ?? '-'}\nFaculdade: ${item['faculdadeNome'] ?? '-'}';
                    } else if (widget.endpoint == 'Estudante' ||
                        widget.endpoint == 'Colaborador') {
                      subtitle =
                          'CPF: ${item['cpf'] ?? '-'}\nEmail: ${item['email'] ?? '-'}';
                    } else {
                      subtitle = 'Detalhes não disponíveis';
                    }

                    return GestureDetector(
                      onTap: () {
                        String id = items[index]['id'].toString();
                        _verDetalhes(widget.endpoint, id);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: AppColors.lightGreyColor,
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            item['nome'] ?? 'Nome não disponível',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(subtitle),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
