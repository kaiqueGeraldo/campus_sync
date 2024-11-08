import 'package:campus_sync/src/controllers/listagem_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = ListagemController();
    _futureList = _controller.listar(widget.endpoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Listagem de ${widget.endpoint}'),
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
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              final titleField = widget.fieldMapping['title'] ?? 'nome';

              return ListTile(
                title: Text(item[titleField] ?? 'Nome não disponível'),
                subtitle: Text(
                  _controller.getSubtitleText(widget.fieldMapping, item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
