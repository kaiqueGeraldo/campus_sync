import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:flutter/material.dart';

class CadastroColaboradorPage extends StatefulWidget {
  final String endpoint;
  const CadastroColaboradorPage({
    super.key,
    required this.endpoint,
  });

  @override
  State<CadastroColaboradorPage> createState() =>
      _CadastroColaboradorPageState();
}

class _CadastroColaboradorPageState extends State<CadastroColaboradorPage> {
  late CadastroController controller;

  bool isDadosColaboradorExpanded = true;
  bool isDocumentosExpanded = false;
  bool isInformacoesPaisExpanded = false;
  bool isEnderecoExpanded = false;
  bool naoConstaPai = false;
  bool naoConstaMae = false;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();

  }

  Widget _buildTextInput(
    String field, {
    bool enabled = true,
    bool disabled = false,
    EdgeInsets? customPadding,
  }) {
    String labelText = controller.fieldNames[field] ?? field;
    TextInputType keyboardType = controller.getKeyboardType(field);
    int? maxLength = controller.getMaxLength(field);

    return Padding(
      padding: customPadding ?? const EdgeInsets.only(bottom: 16),
      child: CustomInputTextCadastro(
        controller: controller.controllers[field] as TextEditingController,
        labelText: labelText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enabled: enabled && !disabled,
        validator: (value) {
          if (!disabled && (value == null || value.isEmpty)) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
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

  Widget _buildCard({
    required String title,
    required IconData icon,
    required bool initiallyExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Card(
      color: AppColors.lightGreyColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        backgroundColor: AppColors.lightGreyColor,
        iconColor: initiallyExpanded ? AppColors.buttonColor : Colors.black,
        leading: Icon(
          icon,
          color: initiallyExpanded ? AppColors.buttonColor : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: initiallyExpanded ? AppColors.buttonColor : Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
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
              _buildCard(
                title: 'Dados do Colaborador',
                icon: Icons.person,
                initiallyExpanded: isDadosColaboradorExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDadosColaboradorExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('NumeroRegistro'),
                  _buildTextInput('DataAdmissao'),
                  _buildTextInput('Nome'),
                  _buildTextInput('Email'),
                  _buildTextInput('DataNascimento'),
                  _buildTextInput('Telefone'),
                ],
              ),
              _buildCard(
                title: 'Documentos',
                icon: Icons.file_copy,
                initiallyExpanded: isDocumentosExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDocumentosExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('CPF'),
                  _buildTextInput('RG'),
                  _buildDropdown('EstadoCivil'),
                  _buildTextInput('TituloEleitor'),
                  _buildDropdown('Nacionalidade'),
                  _buildDropdown('Cor/Raca/Etnia'),
                  _buildDropdown('Escolaridade'),
                ],
              ),
              _buildCard(
                title: 'Informações dos Pais',
                icon: Icons.family_restroom,
                initiallyExpanded: isInformacoesPaisExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isInformacoesPaisExpanded = expanded;
                  });
                },
                children: [
                  // Campos do Pai
                  _buildTextInput(
                    'NomePai',
                    disabled: naoConstaPai,
                  ),
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    value: naoConstaPai,
                    onChanged: (value) {
                      setState(() {
                        naoConstaPai = value ?? false;
                        if (naoConstaPai) {
                          controller.controllers['NomePai']?.clear();
                        }
                      });
                    },
                    title: const Text('Não consta'),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.buttonColor,
                  ),
                  // Campos da Mãe
                  _buildTextInput(
                    'NomeMae',
                    disabled: naoConstaMae,
                  ),
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    value: naoConstaMae,
                    onChanged: (value) {
                      setState(() {
                        naoConstaMae = value ?? false;
                        if (naoConstaMae) {
                          controller.controllers['NomeMae']?.clear();
                        }
                      });
                    },
                    title: const Text('Não consta'),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.buttonColor,
                  ),
                ],
              ),
              _buildCard(
                title: 'Endereço',
                icon: Icons.home,
                initiallyExpanded: isEnderecoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isEnderecoExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('EnderecoRua'),
                  _buildTextInput('EnderecoCidade'),
                  _buildTextInput('EnderecoEstado'),
                  _buildTextInput('EnderecoCEP'),
                ],
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
