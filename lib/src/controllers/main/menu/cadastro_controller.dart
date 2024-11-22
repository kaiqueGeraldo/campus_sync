import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
      } else {
        controllers[key] = _getMaskedController(key, value ?? '');
      }
    });
  }

  TextEditingController _getMaskedController(
      String field, String initialValue) {
    if (field == 'CPF') return MaskedTextController(mask: '000.000.000-00', text: initialValue);
    if (field == 'Celular') return MaskedTextController(mask: '(00) 00000-0000', text: initialValue);
    if (field == 'EnderecoCEP') return MaskedTextController(mask: '00000-000', text: initialValue);
    if (field == 'DataMatricula' || field == 'DataNascimento') return MaskedTextController(mask: '00/00/0000', text: initialValue);
    return TextEditingController(text: initialValue);
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
    if (field == 'TipoFacul') {
      return const [
        DropdownMenuItem(value: 1, child: Text('Pública')),
        DropdownMenuItem(value: 2, child: Text('Privada')),
        DropdownMenuItem(value: 3, child: Text('Militar')),
      ];
    } else if (field == 'PeriodoCurso') {
      return const [
        DropdownMenuItem(value: 1, child: Text('Manhã')),
        DropdownMenuItem(value: 2, child: Text('Tarde')),
        DropdownMenuItem(value: 3, child: Text('Noite')),
      ];
    } else if (field == 'PeriodoTurma') {
      return const [
        DropdownMenuItem(value: 1, child: Text('Manhã')),
        DropdownMenuItem(value: 2, child: Text('Tarde')),
        DropdownMenuItem(value: 3, child: Text('Noite')),
        DropdownMenuItem(value: 4, child: Text('Integral')),
      ];
    }
    return [];
  }

  Future<void> cadastrar(BuildContext context, String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      CustomSnackbar.show(context, 'Erro: Universidade não identificada.');
      return;
    }

    // Formata os dados do formulário
    final Map<String, dynamic> formData = _formatFormData(universidadeId);

    // Chama o método de cadastro na API
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

    // Obtém dados dos controllers
    controllers.forEach((key, controller) {
      formData[key] = controller.text;
    });

    // Obtém valores dos dropdowns
    dropdownValues.forEach((key, value) {
      formData[key] = value;
    });

    // Adiciona o ID da universidade
    formData['universidadeId'] = int.parse(universidadeId);

    // Mapeia os campos para o formato esperado pela API
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

    // Adiciona o endereço como um objeto aninhado
    formData['endereco'] = {
      'rua': formData.remove('EnderecoRua') ?? '',
      'cidade': formData.remove('EnderecoCidade') ?? '',
      'estado': formData.remove('EnderecoEstado') ?? '',
      'cep': formData.remove('EnderecoCEP') ?? '',
    };

    return formData;
  }

  bool isEnderecoField(String field) {
    return field.startsWith('Endereco'); // Identifica campos de endereço
  }
}
