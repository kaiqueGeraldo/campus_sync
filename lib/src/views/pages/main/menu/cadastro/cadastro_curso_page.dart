import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:flutter/material.dart';

class CadastroCursoPage extends StatefulWidget {
  final String endpoint;
    final Map<String, dynamic> initialData;

  const CadastroCursoPage({
    super.key,
    required this.endpoint,
    required this.initialData,
  });

  @override
  State<CadastroCursoPage> createState() => _CadastroCursoPageState();
}

class _CadastroCursoPageState extends State<CadastroCursoPage> {
  late CadastroController controller;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    controller.initControllers(widget.initialData);
    print('Initial Data: ${widget.initialData}');
  }

  Widget _buildDropdown(String field) {
    List<DropdownMenuItem<int>> items = controller.getDropdownItems(field);
    String labelText = controller.fieldNames[field] ?? field;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: controller.dropdownValues[field] as int?,
        items: items,
        onChanged: (newValue) {
          setState(() {
            controller.dropdownValues[field] = newValue;
            print('Dropdown $field updated to $newValue');
          });
        },
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
        dropdownColor: AppColors.lightGreyColor,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        validator: (value) {
          if (value == null) {
            return 'Por favor, selecione uma opção';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextInput(String field) {
    String labelText = controller.fieldNames[field] ?? field;

    TextInputType keyboardType = controller.getKeyboardType(field);
    int? maxLength = controller.getMaxLength(field);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomInputTextCadastro(
        controller: controller.controllers[field] as TextEditingController,
        labelText: labelText,
        keyboardType: keyboardType,
        maxLength: maxLength,
      ),
    );
  }

  bool isDadosEntidadeExpanded = true;
  bool isEnderecoExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasEnderecoFields = controller.controllers.keys
        .any((field) => controller.isEnderecoField(field));

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
              Card(
                color: AppColors.lightGreyColor,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  backgroundColor: AppColors.lightGreyColor,
                  iconColor: isDadosEntidadeExpanded
                      ? AppColors.buttonColor
                      : Colors.black,
                  leading: Icon(
                    Icons.cases_rounded,
                    color: isDadosEntidadeExpanded
                        ? AppColors.buttonColor
                        : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  initiallyExpanded: isDadosEntidadeExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDadosEntidadeExpanded = expanded;
                    });
                  },
                  title: Text(
                    'Dados ${widget.endpoint}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDadosEntidadeExpanded
                          ? AppColors.buttonColor
                          : Colors.black,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...controller.controllers.keys
                                .where((field) =>
                                    !controller.isEnderecoField(field))
                                .map((field) => _buildTextInput(field)),
                            ...controller.dropdownValues.keys
                                .where((field) =>
                                    !controller.isEnderecoField(field))
                                .map((field) => _buildDropdown(field)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasEnderecoFields)
                Card(
                  color: AppColors.lightGreyColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    iconColor: isEnderecoExpanded
                        ? AppColors.buttonColor
                        : Colors.black,
                    leading: Icon(
                      Icons.home_rounded,
                      color: isEnderecoExpanded
                          ? AppColors.buttonColor
                          : Colors.black,
                    ),
                    backgroundColor: AppColors.lightGreyColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    initiallyExpanded: isEnderecoExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        isEnderecoExpanded = expanded;
                      });
                    },
                    title: Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEnderecoExpanded
                            ? AppColors.buttonColor
                            : Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...controller.controllers.keys
                                  .where((field) =>
                                      controller.isEnderecoField(field))
                                  .map((field) => _buildTextInput(field)),
                              ...controller.dropdownValues.keys
                                  .where((field) =>
                                      controller.isEnderecoField(field))
                                  .map((field) => _buildDropdown(field)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
