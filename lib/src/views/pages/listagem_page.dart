import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  Future<List<dynamic>> _listar() async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      throw Exception('Erro: Universidade não identificada.');
    }

    final response = await http.get(
      Uri.parse(
          'https://campussyncapi-cvgwgqawd2etfqfa.canadacentral-01.azurewebsites.net/api/${widget.endpoint}?universidadeId=$universidadeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Listagem de ${widget.endpoint}'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _listar(),
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
              final subtitleField1 = widget.fieldMapping['subtitle1'] ?? 'cpf';
              final subtitleField2 =
                  widget.fieldMapping['subtitle2'] ?? 'email';

              return ListTile(
                title: Text(item[titleField] ?? 'Nome não disponível'),
                subtitle: Text(
                    '${item[subtitleField1]?.toString() ?? 'CPF não disponível'}, ${item[subtitleField2] ?? 'Email não disponível'}'),
              );
            },
          );
        },
      ),
    );
  }
}
