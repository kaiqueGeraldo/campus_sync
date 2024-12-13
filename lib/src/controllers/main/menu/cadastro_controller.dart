import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> cursosSelecionados = [];
  final List<int> cursosOferecidos = [];
  final List<String> disciplinasSelecionados = [];
  final List<int> disciplinasOferecidos = [];
  final Map<String, TextEditingController> controllers = {};
  final Map<String, dynamic> dropdownValues = {};
  final Map<String, String> fieldNames = {
    'CapacidadeMaxima': 'Capacidade Máxima',
    'CPF': 'CPF',
    'Cor/Raca/Etnia': 'Cor/Raça/Etnia',
    'CursoId': 'Curso',
    'DataAdmissao': 'Data de Admissão',
    'DataMatricula': 'Data da Matrícula',
    'DataNascimento': 'Data de Nascimento',
    'Descricao': 'Descrição',
    'Email': 'E-mail',
    'EmailResponsavel': 'E-mail do responsável',
    'EnderecoCEP': 'CEP',
    'EnderecoCidade': 'Cidade',
    'EnderecoEstado': 'Estado',
    'EnderecoLogradouro': 'Logradouro',
    'EnderecoNumero': 'Numero',
    'EnderecoBairro': 'Bairro',
    'EstadoCivil': 'Estado Cívil',
    'EstudanteId': 'Estudante',
    'FaculdadeId': 'Faculdade',
    'Formacoes': 'Formações',
    'Nome': 'Nome',
    'NomeMae': 'Nome da Mãe',
    'NomePai': 'Nome do Pai',
    'NumeroMatricula': 'N° de Matrícula',
    'NumeroRegistro': 'N° de Registro',
    'PeriodoCurso': 'Período do Curso',
    'PeriodoTurma': 'Turma',
    'TelefoneMae': 'Telefone Mãe',
    'TelefonePai': 'Telefone Pai',
    'TipoFacul': 'Tipo de Faculdade',
    'TituloEleitor': 'Título de Eleitor',
    'TurmaId': 'Turma',
  };

  Future _recuperarCPF() async {
    final prefs = await SharedPreferences.getInstance();
    String? userCPF = prefs.getString('userCPF') ?? '';

    return userCPF;
  }

  void initControllers(Map<String, dynamic> initialData) {
    initialData.forEach((key, value) {
      if (isDropdownField(key)) {
        dropdownValues[key] = value is int ? value : null;
      } else if (key == 'CursosOferecidos' || key == 'DisciplinasOferecidos') {
        cursosOferecidos.clear();
        if (value is List) {
          cursosOferecidos.addAll(value.map<int>((e) => e as int));
        }
      } else {
        controllers[key] = getMaskedController(key, value?.toString() ?? '');
      }
    });
  }

  void resetControllers() {
    controllers.forEach((key, controller) => controller.clear());
    dropdownValues.clear();
  }

  TextEditingController getMaskedController(
      String field, String initialValue) {
    switch (field) {
      case 'CPF':
        return MaskedTextController(mask: '000.000.000-00', text: initialValue);
      case 'CNPJ':
        return MaskedTextController(
            mask: '00.000.000/0001-00', text: initialValue);
      case 'RG':
        return MaskedTextController(mask: '00.000.000-0', text: initialValue);
      case 'Celular':
      case 'Telefone':
        return MaskedTextController(
            mask: '(00) 00000-0000', text: initialValue);
      case 'EnderecoCEP':
        return MaskedTextController(mask: '00000-000', text: initialValue);
      case 'DataMatricula':
      case 'DataNascimento':
      case 'DataAdmissao':
        return MaskedTextController(mask: '00/00/0000', text: initialValue);
      default:
        return TextEditingController(text: initialValue);
    }
  }

  int? getMaxLength(String field) {
    switch (field) {
      case 'Mensalidade':
        return 12;
      default:
        return 50;
    }
  }

  TextInputType getKeyboardType(String field) {
    switch (field) {
      case 'CPF':
      case 'CNPJ':
      case 'Mensalidade':
      case 'Celular':
      case 'Telefone':
      case 'EnderecoCEP':
        return TextInputType.number;
      case 'Email':
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  bool isDropdownField(String field) {
    return field == 'TipoFacul' ||
        field == 'PeriodoCurso' ||
        field == 'Turmas' ||
        field == 'Curso' ||
        field == 'EstadoCivil' ||
        field == 'Nacionalidade' ||
        field == 'Escolaridade' ||
        field == 'Cor/Raca/Etnia';
  }

  List<DropdownMenuItem<int>> getDropdownItems(String field,
      {int? faculdadeId}) {
    switch (field) {
      case 'TipoFacul':
        return const [
          DropdownMenuItem(value: 0, child: Text('Pública')),
          DropdownMenuItem(value: 1, child: Text('Privada')),
          DropdownMenuItem(value: 2, child: Text('Militar')),
        ];
      case 'PeriodoCurso':
        return const [
          DropdownMenuItem(value: 0, child: Text('Matutino')),
          DropdownMenuItem(value: 1, child: Text('Vespertino')),
          DropdownMenuItem(value: 2, child: Text('Noturno')),
          DropdownMenuItem(value: 3, child: Text('Integral')),
        ];
      case 'Turmas':
        return const [
          DropdownMenuItem(value: 1, child: Text('1')),
          DropdownMenuItem(value: 2, child: Text('2')),
          DropdownMenuItem(value: 3, child: Text('3')),
          DropdownMenuItem(value: 4, child: Text('4')),
        ];
      case 'EstadoCivil':
        return const [
          DropdownMenuItem(value: 0, child: Text('Solteiro')),
          DropdownMenuItem(value: 1, child: Text('Casado')),
          DropdownMenuItem(value: 2, child: Text('Divorciado')),
          DropdownMenuItem(value: 3, child: Text('Viúvo')),
        ];
      case 'Nacionalidade':
        return const [
          DropdownMenuItem(value: 0, child: Text('Brasileiro')),
          DropdownMenuItem(value: 1, child: Text('Estrangeiro')),
        ];
      case 'Cor/Raca/Etnia':
        return const [
          DropdownMenuItem(value: 0, child: Text('Branco')),
          DropdownMenuItem(value: 1, child: Text('Pardo')),
          DropdownMenuItem(value: 2, child: Text('Negro')),
          DropdownMenuItem(value: 3, child: Text('Amarelo')),
          DropdownMenuItem(value: 4, child: Text('Indígena')),
        ];
      case 'Escolaridade':
        return const [
          DropdownMenuItem(value: 0, child: Text('Ensino Médio')),
          DropdownMenuItem(value: 1, child: Text('Graduação')),
          DropdownMenuItem(value: 2, child: Text('Pós-Graduação')),
          DropdownMenuItem(value: 3, child: Text('Mestrado')),
          DropdownMenuItem(value: 4, child: Text('Doutorado')),
        ];
      case 'CursosRelacionados':
        if (faculdadeId == null) {
          throw ArgumentError(
              "Para 'CursosRelacionados', o parâmetro 'faculdadeId' é obrigatório.");
        }
        final cursos = [
          {'id': 1, 'nome': 'Curso A', 'faculdadeId': 1},
          {'id': 2, 'nome': 'Curso B', 'faculdadeId': 2},
          {'id': 3, 'nome': 'Curso C', 'faculdadeId': 1},
        ];

        return cursos
            .where((curso) => curso['faculdadeId'] == faculdadeId)
            .map((curso) => DropdownMenuItem<int>(
                  value: curso['id'] as int,
                  child: Text(curso['nome'].toString()),
                ))
            .toList();
      default:
        return [];
    }
  }

  Future<void> cadastrar(BuildContext context, String endpoint) async {
    List<String> requiredFields = [];

    switch (endpoint) {
      case 'Faculdade':
        requiredFields = [
          'Nome',
          'CNPJ',
          'Telefone',
          'EmailResponsavel',
          'TipoFacul',
          'CursosOferecidos',
        ];
        break;
      case 'Curso':
        requiredFields = ['Nome', 'Descricao', 'Mensalidade', 'FaculdadeId'];
        break;
      case 'Estudante':
        requiredFields = [
          'Nome',
          'Email',
          'DataNascimento',
          'EnderecoCEP',
          'EnderecoLogradouro',
          'EnderecoNumero',
          'EnderecoBairro',
          'EnderecoCidade',
          'EnderecoEstado',
          'userCPF'
        ];
        break;
      default:
        CustomSnackbar.show(context, 'Endpoint desconhecido!');
        return;
    }

    final formData = await formatFormData(requiredFields);
    final response = await ApiService().cadastrarDados(endpoint, formData);

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      CustomSnackbar.show(context, 'Cadastro realizado com sucesso!');
      Navigator.pop(context);
    } else {
      CustomSnackbar.show(
          context, 'Erro ao cadastrar: ${response?.body ?? 'Desconhecido'}');
    }
  }

  Future<Map<String, dynamic>> formatFormData(
      List<String> requiredFields) async {
    final Map<String, dynamic> formData = {};

    controllers.forEach((key, controller) {
      formData[key] = controller.text;
    });

    dropdownValues.forEach((key, value) {
      formData[key] = value;
    });

    if (requiredFields.contains('userCPF')) {
      formData['userCPF'] = await _recuperarCPF();
    }

    if (requiredFields.any((field) => field.startsWith('Endereco'))) {
      formData['endereco'] = {
        'cep': formData.remove('EnderecoCEP') ?? '',
        'logradouro': formData.remove('EnderecoLogradouro') ?? '',
        'numero': formData.remove('EnderecoNumero') ?? '',
        'bairro': formData.remove('EnderecoBairro') ?? '',
        'cidade': formData.remove('EnderecoCidade') ?? '',
        'estado': formData.remove('EnderecoEstado') ?? '',
      };
    }

      if (requiredFields.contains('CursosOferecidos')) {
    formData['CursosOferecidos'] = cursosOferecidos.map((curso) => curso.toString()).toList();
  }


    // Retorna apenas os campos necessários
    return formData..removeWhere((key, value) => value == null);
  }

  bool isEnderecoField(String field) {
    return field.startsWith('Endereco');
  }
}
