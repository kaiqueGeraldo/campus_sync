import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> cursosSelecionados = [];
  final List<int> cursosOferecidos = []; // Armazena os IDs dos cursos
  final Map<String, TextEditingController> controllers = {};
  final Map<String, dynamic> dropdownValues = {};
  final Map<String, String> fieldNames = {
    'TipoFacul': 'Tipo de Faculdade',
    'PeriodoCurso': 'Período do Curso',
    'Nome': 'Nome',
    'Email': 'E-mail',
    'CPF': 'CPF',
    'NumEstudante': 'N° Estudante',
    'Formacoes': 'Formações',
    'Salario': 'Salário',
    'EnderecoRua': 'Rua',
    'EnderecoCidade': 'Cidade',
    'EnderecoEstado': 'Estado',
    'EnderecoCEP': 'CEP',
    'UniversidadeId': 'Universidade',
    'EstudanteId': 'Estudante',
    'CursoId': 'Curso',
    'TurmaId': 'Turma',
    'PeriodoTurma': 'Turma',
    'DataMatricula': 'Data da Matrícula',
    'DataNascimento': 'Data de Nascimento',
    'CapacidadeMaxima': 'Capacidade Máxima',
    'FaculdadeId': 'Faculdade',
    'Descricao': 'Descrição',
    'Mensalidade': 'Mensalidade',
    'Celular': 'Celular',
    'Senha': 'Senha',
  };

  void initControllers(Map<String, dynamic> initialData) {
    initialData.forEach((key, value) {
      if (isDropdownField(key)) {
        dropdownValues[key] = value is int ? value : null;
      } else if (key == 'CursosOferecidos') {
        cursosOferecidos.clear();
        if (value is List) {
          cursosOferecidos.addAll(value.map<int>((e) => e as int));
        }
      } else {
        controllers[key] = _getMaskedController(key, value?.toString() ?? '');
      }
    });
  }

  void resetControllers() {
    controllers.forEach((key, controller) => controller.clear());
    dropdownValues.clear();
  }

  TextEditingController _getMaskedController(
      String field, String initialValue) {
    switch (field) {
      case 'CPF':
        return MaskedTextController(mask: '000.000.000-00', text: initialValue);
      case 'Celular':
      case 'Telefone':
        return MaskedTextController(
            mask: '(00) 00000-0000', text: initialValue);
      case 'EnderecoCEP':
        return MaskedTextController(mask: '00000-000', text: initialValue);
      case 'DataMatricula':
      case 'DataNascimento':
        return MaskedTextController(mask: '00/00/0000', text: initialValue);
      default:
        return TextEditingController(text: initialValue);
    }
  }

  int? getMaxLength(String field) {
    switch (field) {
      default:
        return 50;
    }
  }

  TextInputType getKeyboardType(String field) {
    switch (field) {
      case 'CPF':
      case 'NumEstudante':
      case 'Celular':
      case 'Telefone':
      case 'EnderecoCEP':
      case 'Mensalidade':
      case 'DataMatricula':
        return TextInputType.number;
      case 'Salario':
        return const TextInputType.numberWithOptions(decimal: true);
      case 'Email':
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  bool isDropdownField(String field) {
    return field == 'TipoFacul' ||
        field == 'PeriodoCurso' ||
        field == 'PeriodoTurma';
  }

  List<DropdownMenuItem<int>> getDropdownItems(String field) {
    switch (field) {
      case 'TipoFacul':
        return const [
          DropdownMenuItem(value: 1, child: Text('Pública')),
          DropdownMenuItem(value: 2, child: Text('Privada')),
          DropdownMenuItem(value: 3, child: Text('Militar')),
        ];
      case 'PeriodoCurso':
        return const [
          DropdownMenuItem(value: 1, child: Text('Manhã')),
          DropdownMenuItem(value: 2, child: Text('Tarde')),
          DropdownMenuItem(value: 3, child: Text('Noite')),
        ];
      case 'PeriodoTurma':
        return const [
          DropdownMenuItem(value: 1, child: Text('Manhã')),
          DropdownMenuItem(value: 2, child: Text('Tarde')),
          DropdownMenuItem(value: 3, child: Text('Noite')),
          DropdownMenuItem(value: 4, child: Text('Integral')),
        ];
      default:
        return [];
    }
  }

  Future<void> cadastrar(BuildContext context, String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      CustomSnackbar.show(context, 'Erro: Universidade não identificada.');
      return;
    }

    final Map<String, dynamic> formData = _formatFormData(universidadeId);
    final response = await ApiService().cadastrarDados(endpoint, formData);

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      CustomSnackbar.show(context, 'Cadastro realizado com sucesso!');
      Navigator.pop(context);
    } else {
      CustomSnackbar.show(context,
          'Erro ao cadastrar: ${response?.reasonPhrase ?? 'Desconhecido'}');
    }
  }

  Map<String, dynamic> _formatFormData(String universidadeId) {
    final Map<String, dynamic> formData = {};

    controllers.forEach((key, controller) {
      formData[key] = controller.text;
    });

    dropdownValues.forEach((key, value) {
      formData[key] = value;
    });

    formData['universidadeId'] = int.parse(universidadeId);

    formData['faculdadeId'] = formData.remove('FaculdadeId');
    formData['estudanteId'] = formData.remove('EstudanteId');
    formData['turmaId'] = formData.remove('TurmaId');
    formData['nome'] = formData.remove('Nome');
    formData['tipo'] = formData.remove('TipoFacul');
    formData['descricao'] = formData.remove('Descricao');
    formData['mensalidade'] = formData.remove('Mensalidade');
    formData['email'] = formData.remove('Email');
    formData['telefone'] = formData.remove('Telefone');
    formData['dataNascimento'] = formData.remove('DataNascimento');
    formData['numEstudante'] = formData.remove('NumEstudante');
    formData['periodo'] = formData.remove('PeriodoTurma');
    formData['capacidadeMaxima'] = formData.remove('CapacidadeMaxima');
    formData['cursosOferecidos'] = cursosSelecionados.join(',');

    formData['endereco'] = {
      'rua': formData.remove('EnderecoRua') ?? '',
      'cidade': formData.remove('EnderecoCidade') ?? '',
      'estado': formData.remove('EnderecoEstado') ?? '',
      'cep': formData.remove('EnderecoCEP') ?? '',
    };

    return formData;
  }

  bool isEnderecoField(String field) {
    return field.startsWith('Endereco');
  }
}
