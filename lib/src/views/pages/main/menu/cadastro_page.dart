import 'package:flutter/material.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';

class CadastroPage extends StatefulWidget {
  final String endpoint;
  final Map<String, dynamic> initialData;

  const CadastroPage({
    super.key,
    required this.endpoint,
    required this.initialData,
  });

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  late CadastroController controller;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    controller.initControllers(widget.initialData);
  }

  Widget _buildDropdown(
      String field, dynamic value, Function(dynamic) onChanged) {
    List<DropdownMenuItem<String>> items = [];
    String labelText =
        controller.fieldNames[field] ?? field; // Use o nome personalizado

    if (field == 'TipoFacul') {
      items = const [
        DropdownMenuItem(value: 'Publica', child: Text('Pública')),
        DropdownMenuItem(value: 'Privada', child: Text('Privada')),
        DropdownMenuItem(value: 'Militar', child: Text('Militar')),
      ];
    } else if (field == 'PeriodoCurso') {
      items = const [
        DropdownMenuItem(value: 'Manha', child: Text('Manhã')),
        DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
        DropdownMenuItem(value: 'Noite', child: Text('Noite')),
      ];
    }

    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: (newValue) {
        setState(() {
          onChanged(newValue);
        });
      },
      decoration: InputDecoration(labelText: labelText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione uma opção';
        }
        return null;
      },
    );
  }

  Widget _buildTextInput(String field) {
    String labelText = controller.fieldNames[field] ?? field;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller.controllers[field],
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: AppColors.backgroundBlueColor),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: AppColors.backgroundBlueColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo ${controller.fieldNames[field]} é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Cadastro de ${widget.endpoint}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dados ${widget.endpoint}'.toUpperCase(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Icon(Icons.featured_play_list_outlined),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    ...controller.controllers.keys.map((field) {
                      if (controller.isDropdownField(field)) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildDropdown(
                            field,
                            controller.dropdownValues[field],
                            (value) {
                              setState(() {
                                controller.dropdownValues[field] = value;
                              });
                            },
                          ),
                        );
                      } else {
                        return _buildTextInput(field);
                      }
                    }),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                        onPressed: () {
                          controller.cadastrar(context, widget.endpoint);
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
            ],
          ),
        ),
      ),
    );
  }
}
