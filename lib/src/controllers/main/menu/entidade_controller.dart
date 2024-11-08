import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntidadeController {
  final String endpoint;
  late Map<String, dynamic> initialData;
  late Map<String, String> fieldMapping;
  String? universidadeId;

  EntidadeController(this.endpoint) {
    _initializeFieldMappings();
    _initializeInitialData();
  }

  void _initializeFieldMappings() {
    fieldMapping = {
          'Matriculas': {
            'title': 'estudante',
            'subtitle1': 'curso',
            'subtitle2': 'periodoCurso'
          },
          'Faculdades': {
            'title': 'nomeFaculdade',
            'subtitle1': 'tipoFacul',
            'subtitle2': 'universidade'
          },
          'Estudantes': {
            'title': 'nome',
            'subtitle1': 'cpf',
            'subtitle2': 'email',
          },
          'Professores': {
            'title': 'nome',
            'subtitle1': 'cpf',
            'subtitle2': 'departamento',
          },
          'Funcionarios': {
            'title': 'nome',
            'subtitle1': 'cargo',
            'subtitle2': 'cpf',
          },
          'Cursos': {
            'title': 'descricao',
            'subtitle1': 'mensalidade',
            'subtitle2': 'faculdade',
          },
          'Universidades': {
            'title': 'nomeUniversidade',
            'subtitle1': 'sigla',
            'subtitle2': 'cidade',
          },
          'Enderecos': {
            'title': 'logradouro',
            'subtitle1': 'numero',
            'subtitle2': 'cidade',
          },
          'FaculdadeProfessor': {
            'title': 'professor',
            'subtitle1': 'faculdade',
            'subtitle2': 'departamento',
          },
          'Users': {
            'title': 'nome',
            'subtitle1': 'email',
            'subtitle2': 'cpf',
          },
        }[endpoint] ??
        {};
  }

  void _initializeInitialData() {
    initialData = {
          'Matriculas': {
            'EstudanteId': null,
            'CursoId': null,
            'PeriodoCurso': 'Manha',
            'DataMatricula': _formatarData(DateTime.now().toString()),
          },
          'Faculdades': {
            'Nome': '',
            'EnderecoRua': '',
            'EnderecoCidade': '',
            'EnderecoEstado': '',
            'EnderecoCEP': null,
            'TipoFacul': 'Privada',
            'UniversidadeId': universidadeId,
          },
          'Estudantes': {
            'Nome': '',
            'Email': '',
            'CPF': '',
            'NumEstudante': null,
            'EnderecoRua': '',
            'EnderecoCidade': '',
            'EnderecoEstado': '',
            'EnderecoCEP': null,
          },
          'Professores': {
            'Nome': '',
            'Email': '',
            'Formacoes': '',
            'Salario': null,
            'EnderecoRua': '',
            'EnderecoCidade': '',
            'EnderecoEstado': '',
            'EnderecoCEP': null,
          },
          'Funcionarios': {
            'Nome': '',
            'Email': '',
            'Cargo': '',
            'Salario': null,
            'EnderecoRua': '',
            'EnderecoCidade': '',
            'EnderecoEstado': '',
            'EnderecoCEP': null,
          },
          'Cursos': {
            'Descricao': '',
            'Mensalidade': null,
            'FaculdadeId': null,
          },
          'Universidades': {
            'Nome': '',
            'EnderecoRua': '',
            'EnderecoCidade': '',
            'EnderecoEstado': '',
            'EnderecoCEP': null,
            'ContatoInfo': '',
          },
          'Enderecos': {
            'Rua': '',
            'Cidade': '',
            'Estado': '',
            'CEP': null,
          },
          'FaculdadeProfessor': {
            'ProfessorId': null,
            'FaculdadeId': null,
          },
          'Users': {
            'CPF': '',
            'Nome': '',
            'Email': '',
            'Celular': '',
            'Senha': '',
          },
        }[endpoint] ??
        {};
  }

  String _formatarData(String data) {
    var formatador = DateFormat('dd/MM/yyyy');
    DateTime dataConvertida = DateTime.parse(data);
    return formatador.format(dataConvertida);
  }

  void navigateToCadastroPage(BuildContext context, Widget cadastroPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => cadastroPage),
    );
  }

  void navigateToListagemPage(BuildContext context, Widget listagemPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => listagemPage),
    );
  }

  Future<void> loadUniversidadeId() async {
    final prefs = await SharedPreferences.getInstance();
    universidadeId = prefs.getString('universidadeId');
    if (universidadeId != null) {
      initialData['UniversidadeId'] = universidadeId;
    }
  }
}
