import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
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
        controllers[key] = TextEditingController(text: value?.toString() ?? '');
      }
    });
  }

  bool isDropdownField(String field) {
    return field == 'TipoFacul' || field == 'PeriodoCurso';
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
}
