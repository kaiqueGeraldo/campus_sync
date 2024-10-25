import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CadastroPage extends StatefulWidget {
  final String endpoint;
  final Map<String, dynamic> initialData;

  const CadastroPage(
      {super.key, required this.endpoint, required this.initialData});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _dropdownValues = {};
  final bool _focusColor = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    widget.initialData.forEach((key, value) {
      if (_isDropdownField(key)) {
        _dropdownValues[key] = value;
      } else {
        _controllers[key] =
            TextEditingController(text: value?.toString() ?? '');
      }
    });
  }

  bool _isDropdownField(String field) {
    return field == 'TipoFacul' || field == 'PeriodoCurso';
  }

  Widget _buildDropdown(
      String field, dynamic value, Function(dynamic) onChanged) {
    if (field == 'TipoFacul') {
      return DropdownButtonFormField<String>(
        value: value ?? 'Publica',
        items: const [
          DropdownMenuItem(value: 'Publica', child: Text('Pública')),
          DropdownMenuItem(value: 'Privada', child: Text('Privada')),
          DropdownMenuItem(value: 'Militar', child: Text('Militar')),
        ],
        onChanged: (newValue) {
          setState(() {
            onChanged(newValue);
          });
        },
        decoration: const InputDecoration(labelText: 'Tipo de Faculdade'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, selecione o tipo de faculdade';
          }
          return null;
        },
      );
    } else if (field == 'PeriodoCurso') {
      return DropdownButtonFormField<String>(
        value: value ?? 'Manha',
        items: const [
          DropdownMenuItem(value: 'Manha', child: Text('Manhã')),
          DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
          DropdownMenuItem(value: 'Noite', child: Text('Noite')),
        ],
        onChanged: (newValue) {
          setState(() {
            onChanged(newValue);
          });
        },
        decoration: const InputDecoration(labelText: 'Período do Curso'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, selecione o período do curso';
          }
          return null;
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      String? universidadeId = prefs.getString('universidadeId');

      if (universidadeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erro: Universidade não identificada.')));
        return;
      }

      final Map<String, dynamic> formData = {};
      _controllers.forEach((key, controller) {
        formData[key] = controller.text;
      });

      _dropdownValues.forEach((key, value) {
        formData[key] = value;
      });

      formData['UniversidadeId'] = universidadeId;

      final response = await http.post(
        Uri.parse(
            'https://campussyncapi-cvgwgqawd2etfqfa.canadacentral-01.azurewebsites.net/api/${widget.endpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao cadastrar: ${response.reasonPhrase}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Cadastro de ${widget.endpoint}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ..._controllers.keys.map(
                (field) {
                  if (_isDropdownField(field)) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildDropdown(
                        field,
                        _dropdownValues[field],
                        (value) {
                          setState(() {
                            _dropdownValues[field] = value;
                          });
                        },
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _controllers[field],
                        decoration: InputDecoration(
                          labelText: field.capitalize(),
                          labelStyle: TextStyle(
                            color: _focusColor
                                ? AppColors.greyColor
                                : AppColors.backgroundBlueColor,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.5,
                              color: _focusColor
                                  ? AppColors.greyColor
                                  : AppColors.backgroundBlueColor,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo $field é obrigatório';
                          }
                          return null;
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: const ButtonStyle(
                    elevation: WidgetStatePropertyAll(4),
                    backgroundColor:
                        WidgetStatePropertyAll(AppColors.buttonColor),
                    foregroundColor:
                        WidgetStatePropertyAll(AppColors.textColor),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _cadastrar();
                  },
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
