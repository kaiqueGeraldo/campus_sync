import 'package:campus_sync/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // /// Define os dados iniciais com base no endpoint.
  // Future<void> _initializeInitialData() async {
  //   final userCPF = await _recuperarCPF();

  //   final initialDataMap = {
  //     'Faculdade': {
  //       'Nome': '',
  //       'EnderecoLogradouro': '',
  //       'EnderecoNumero': '',
  //       'EnderecoBairro': '',
  //       'EnderecoCidade': '',
  //       'EnderecoEstado': '',
  //       'EnderecoCEP': null,
  //       'TipoFacul': 'Privada',
  //       'CNPJ': null,
  //       'Telefone': '',
  //       'EmailResponsavel': '',
  //       'CursosOferecidos': [],
  //       'userCpf': userCPF,
  //     },
  //     'Estudante': {
  //       'Nome': '',
  //       'Email': '',
  //       'CPF': '',
  //       'NumeroMatricula': null,
  //       'DataMatricula': _formatarData(DateTime.now().toString()),
  //       'DataNascimento': _formatarData(DateTime.now().toString()),
  //       'RG': '',
  //       'TituloEleitor': '',
  //       'EstadoCivil': '',
  //       'Nacionalidade': '',
  //       'Cor/Raca/Etnia': '',
  //       'Escolaridade': '',
  //       'Telefone': '',
  //       'NomePai': '',
  //       'NomeMae': '',
  //       'TelefonePai': '',
  //       'TelefoneMae': '',
  //       'EnderecoLogradouro': '',
  //       'EnderecoNumero': '',
  //       'EnderecoBairro': '',
  //       'EnderecoCidade': '',
  //       'EnderecoEstado': '',
  //       'EnderecoCEP': null,
  //     },
  //     'Curso': {
  //       //'FaculdadeId': null,
  //       'Curso': '',
  //       'PeriodoCurso': '',
  //       'Turmas': '',
  //       'DisciplinasOferecidos': [],
  //       'Mensalidade': null,
  //     },
  //     'Colaborador': {
  //       'Nome': '',
  //       'Email': '',
  //       'Cargo': '',
  //       'NumeroRegistro': null,
  //       'DataAdmissao': _formatarData(DateTime.now().toString()),
  //       'DataNascimento': _formatarData(DateTime.now().toString()),
  //       'RG': '',
  //       'TituloEleitor': '',
  //       'EstadoCivil': '',
  //       'Nacionalidade': '',
  //       'Cor/Raca/Etnia': '',
  //       'Escolaridade': '',
  //       'Telefone': '',
  //       'NomePai': '',
  //       'NomeMae': '',
  //       'EnderecoLogradouro': '',
  //       'EnderecoNumero': '',
  //       'EnderecoBairro': '',
  //       'EnderecoCidade': '',
  //       'EnderecoEstado': '',
  //       'EnderecoCEP': null,
  //     },
  //     'Universidade': {
  //       'Nome': '',
  //       'CNPJ': '',
  //       'ContatoInfo': '',
  //     },
  //     'Endereco': {
  //       'CEP': null,
  //       'Logradouro': '',
  //       'Numero': '',
  //       'Bairro': '',
  //       'Cidade': '',
  //       'Estado': '',
  //     },
  //   };

  //   initialData = initialDataMap[endpoint] ?? {};
  // }

  /// Formata uma data no formato dd/MM/yyyy.
  String _formatarData(String data) {
    final formatador = DateFormat('dd/MM/yyyy');
    final dataConvertida = DateTime.parse(data);
    return formatador.format(dataConvertida);
  }

  Future<List<Map<String, dynamic>>> carregarItens(String endpoint) async {
    if (['Faculdade', 'Curso', 'Estudante', 'Colaborador']
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


}
