import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:flutter/material.dart';

class AtualizarDadosUniversidadePage extends StatefulWidget {
  final String endpoint;

  const AtualizarDadosUniversidadePage({
    super.key,
    required this.endpoint,
  });

  @override
  State<AtualizarDadosUniversidadePage> createState() =>
      _AtualizarDadosUniversidadePageState();
}

class _AtualizarDadosUniversidadePageState
    extends State<AtualizarDadosUniversidadePage> {
  late CadastroController controller;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Configurar ${widget.endpoint}'),
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
                    'Atualizar',
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
