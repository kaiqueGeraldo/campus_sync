import 'package:campus_sync/src/controllers/main/menu/listagem_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class ListagemPage extends StatefulWidget {
  final String endpoint;
  final Map<String, String> fieldMapping;

  const ListagemPage({
    super.key,
    required this.endpoint,
    required this.fieldMapping,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Listagem de ${widget.endpoint}'),
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
            return const Center(child: Text('Nenhum item encontrado.'));
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
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final titleField = widget.fieldMapping['title'] ?? 'nome';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: AppColors.lightGreyColor,
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          item[titleField] ?? 'Nome não disponível',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _controller.getSubtitleText(
                              widget.fieldMapping, item),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
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
