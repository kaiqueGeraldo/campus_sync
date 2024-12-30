import 'package:campus_sync/src/services/api_service.dart';
import 'package:flutter/material.dart';

class EntidadeController {
  String endpoint;
  late Map<String, String> fieldMapping;

  EntidadeController(this.endpoint);

  /// Inicializa o controlador, configurando mapeamentos e dados iniciais.
  Future<void> initialize() async {
    _initializeFieldMappings();
  }

  /// Define o mapeamento de campos com base no endpoint.
  void _initializeFieldMappings() {
    final mappings = {
      'Faculdade': {
        'title': 'nomeFaculdade',
        'subtitle1': 'tipoFacul',
        'subtitle2': 'endereco',
      },
      'Estudante': {
        'title': 'nome',
        'subtitle1': 'cpf',
        'subtitle2': 'email',
      },
      'Curso': {
        'title': 'descricao',
        'subtitle1': 'mensalidade',
        'subtitle2': 'faculdade',
      },
      'Colaborador': {
        'title': 'nome',
        'subtitle1': 'cargo',
        'subtitle2': 'cpf',
      },
      'Endereco': {
        'title': 'logradouro',
        'subtitle1': 'numero',
        'subtitle2': 'cidade',
      },
    };

    fieldMapping = mappings[endpoint] ?? {};
  }

  /// Navega para a página de cadastro.
  void navigateToCadastroPage(BuildContext context, Widget cadastroPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => cadastroPage),
    );
  }

  /// Navega para a página de listagem.
  void navigateToListagemPage(BuildContext context, Widget listagemPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => listagemPage),
    );
  }

  void navigateToContaPage(BuildContext context, Widget contaPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => contaPage),
    );
  }

  void editarItemPage(BuildContext context, Widget contaPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => contaPage),
    );
  }
}
