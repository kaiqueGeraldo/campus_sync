import 'package:campus_sync/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntidadeController {
  String endpoint;
  late Map<String, dynamic> initialData;
  late Map<String, String> fieldMapping;

  EntidadeController(this.endpoint);

  /// Inicializa o controlador, configurando mapeamentos e dados iniciais.
  Future<void> initialize() async {
    _initializeFieldMappings();
    await _initializeInitialData();
  }

  /// Define o mapeamento de campos com base no endpoint.
  void _initializeFieldMappings() {
    final mappings = {
      'Faculdades': {
        'title': 'nomeFaculdade',
        'subtitle1': 'tipoFacul',
        'subtitle2': 'endereco',
      },
      'Estudantes': {
        'title': 'nome',
        'subtitle1': 'cpf',
        'subtitle2': 'email',
      },
      'Cursos': {
        'title': 'descricao',
        'subtitle1': 'mensalidade',
        'subtitle2': 'faculdade',
      },
      'Colaboradores': {
        'title': 'nome',
        'subtitle1': 'cargo',
        'subtitle2': 'cpf',
      },
      'Enderecos': {
        'title': 'logradouro',
        'subtitle1': 'numero',
        'subtitle2': 'cidade',
      },
    };

    fieldMapping = mappings[endpoint] ?? {};
  }

  /// Define os dados iniciais com base no endpoint.
  Future<void> _initializeInitialData() async {
    final universidadeId = await _loadUniversidadeId();

    final initialDataMap = {
      'Faculdades': {
        'UniversidadeId': universidadeId,
        'Nome': '',
        'EnderecoRua': '',
        'EnderecoCidade': '',
        'EnderecoEstado': '',
        'EnderecoCEP': null,
        'TipoFacul': 'Privada',
        'CNPJ': null,
        'Telefone': '',
        'EmailResponsavel': '',
        'CursosOferecidos': [],
      },
      'Estudantes': {
        'Nome': '',
        'Email': '',
        'CPF': '',
        'NumeroMatricula': null,
        'DataMatricula': _formatarData(DateTime.now().toString()),
        'DataNascimento': _formatarData(DateTime.now().toString()),
        'RG': '',
        'TituloEleitor': '',
        'EstadoCivil': '',
        'Nacionalidade': '',
        'Cor/Raca/Etnia': '',
        'Escolaridade': '',
        'Telefone': '',
        'NomePai': '',
        'NomeMae': '',
        'TelefonePai': '',
        'TelefoneMae': '',
        'EnderecoRua': '',
        'EnderecoCidade': '',
        'EnderecoEstado': '',
        'EnderecoCEP': null,
      },
      'Cursos': {
        //'FaculdadeId': null,
        'Curso': '',
        'PeriodoCurso': '',
        'Turmas': '',
        'DisciplinasOferecidos': [],
        'Mensalidade': null,
      },
      'Colaboradores': {
        'Nome': '',
        'Email': '',
        'Cargo': '',
        'NumeroRegistro': null,
        'DataAdmissao': _formatarData(DateTime.now().toString()),
        'DataNascimento': _formatarData(DateTime.now().toString()),
        'RG': '',
        'TituloEleitor': '',
        'EstadoCivil': '',
        'Nacionalidade': '',
        'Cor/Raca/Etnia': '',
        'Escolaridade': '',
        'Telefone': '',
        'NomePai': '',
        'NomeMae': '',
        'EnderecoRua': '',
        'EnderecoCidade': '',
        'EnderecoEstado': '',
        'EnderecoCEP': null,
      },
      'Universidade': {
        'Nome': '',
        'CNPJ': '',
        'ContatoInfo': '',
      },
      'Enderecos': {
        'Rua': '',
        'Cidade': '',
        'Estado': '',
        'CEP': null,
      },
    };

    initialData = initialDataMap[endpoint] ?? {};
  }

  /// Formata uma data no formato dd/MM/yyyy.
  String _formatarData(String data) {
    final formatador = DateFormat('dd/MM/yyyy');
    final dataConvertida = DateTime.parse(data);
    return formatador.format(dataConvertida);
  }

  Future<List<Map<String, dynamic>>> carregarItens(String endpoint) async {
    if (['Faculdades', 'Cursos', 'Estudantes', 'Colaboradores']
        .contains(endpoint)) {
      final List<dynamic> dados = await ApiService().listarDados(endpoint);
      return dados.map((item) => item as Map<String, dynamic>).toList();
    }

    return [];
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

  /// Carrega o ID da universidade do armazenamento local.
  Future<String?> _loadUniversidadeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('universidadeId');
  }
}
