// ignore_for_file: curly_braces_in_flow_control_structures

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
    'DataMatricula': 'Data da Matrícula',
    'FaculdadeId': 'Faculdade',
    'Descricao': 'Descrição',
    'Mensalidade': 'Mensalidade',
    'Celular': 'Celular',
    'Senha': 'Senha',
  };

  void initControllers(Map<String, dynamic> initialData) {
    initialData.forEach((key, value) {
      if (isDropdownField(key)) {
        dropdownValues[key] = value;
      } else {
        controllers[key] = _getMaskedController(key, value?.toString() ?? '');
      }
    });
  }

  TextEditingController _getMaskedController(
      String field, String initialValue) {
    if (field == 'CPF')
      return MaskedTextController(mask: '000.000.000-00', text: initialValue);
    if (field == 'Celular')
      return MaskedTextController(mask: '(00) 00000-0000', text: initialValue);
    if (field == 'EnderecoCEP')
      return MaskedTextController(mask: '00000-000', text: initialValue);
    if (field == 'DataMatricula')
      return MaskedTextController(mask: '00/00/0000', text: initialValue);
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
      case 'E-mail':
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  bool isDropdownField(String field) {
    return field == 'TipoFacul' || field == 'PeriodoCurso';
  }

  List<DropdownMenuItem<String>> getDropdownItems(String field) {
    if (field == 'TipoFacul') {
      return const [
        DropdownMenuItem(value: 'Publica', child: Text('Pública')),
        DropdownMenuItem(value: 'Privada', child: Text('Privada')),
        DropdownMenuItem(value: 'Militar', child: Text('Militar')),
      ];
    } else if (field == 'PeriodoCurso') {
      return const [
        DropdownMenuItem(value: 'Manha', child: Text('Manhã')),
        DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
        DropdownMenuItem(value: 'Noite', child: Text('Noite')),
      ];
    }
    return [];
  }

  Future<void> cadastrar(BuildContext context, String endpoint) async {
    if (formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      String? universidadeId = prefs.getString('universidadeId');

      if (universidadeId == null) {
        CustomSnackbar.show(context, 'Erro: Universidade não identificada.');
        return;
      }

      final Map<String, dynamic> formData = {};
      controllers.forEach((key, controller) {
        formData[key] = controller.text;
      });
      dropdownValues.forEach((key, value) {
        formData[key] = value;
      });
      formData['UniversidadeId'] = universidadeId;

      final response = await ApiService().cadastrarDados(endpoint, formData);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        CustomSnackbar.show(context, 'Cadastro realizado com sucesso!');
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(
            context, 'Erro ao cadastrar: ${response?.reasonPhrase}');
      }
    }
  }

  bool isEnderecoField(String field) {
    return field.startsWith('Endereco'); // Identifica campos de endereço
  }
}
