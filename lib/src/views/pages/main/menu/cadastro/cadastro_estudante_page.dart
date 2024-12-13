import 'dart:convert';

import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CadastroEstudantePage extends StatefulWidget {
  final String endpoint;
  const CadastroEstudantePage({
    super.key,
    required this.endpoint,
  });

  @override
  State<CadastroEstudantePage> createState() => _CadastroEstudantePageState();
}

class _CadastroEstudantePageState extends State<CadastroEstudantePage> {
  late CadastroController controller;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController rgController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numeroMatriculaController =
      TextEditingController();
  final TextEditingController dataMatriculaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController dataNascimentoController =
      TextEditingController();
  final TextEditingController tituloEleitorController = TextEditingController();
  final TextEditingController nomePaiController = TextEditingController();
  final TextEditingController nomeMaeController = TextEditingController();
  final TextEditingController telefonePaiController = TextEditingController();
  final TextEditingController telefoneMaeController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();

  bool isDadosEstudanteExpanded = true;
  bool isDocumentosExpanded = false;
  bool isInformacoesPaisExpanded = false;
  bool isEnderecoExpanded = false;
  bool isCursoExpanded = false;
  bool naoConstaPai = false;
  bool naoConstaMae = false;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
  }

  @override
  void dispose() {
    logradouroController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();
    nomeController.dispose();
    cpfController.dispose();
    rgController.dispose();
    emailController.dispose();
    numeroMatriculaController.dispose();
    dataMatriculaController.dispose();
    telefoneController.dispose();
    dataNascimentoController.dispose();
    tituloEleitorController.dispose();
    nomePaiController.dispose();
    nomeMaeController.dispose();
    telefonePaiController.dispose();
    telefoneMaeController.dispose();

    super.dispose();
  }

  Future<http.Response?> cadastrarEstudante() async {
    int estadoCivilValue =
        controller.dropdownValues['EstadoCivil'] as int? ?? 0;
    int nacionalidadeValue =
        controller.dropdownValues['Nacionalidade'] as int? ?? 0;
    int corRacaEtniaValue =
        controller.dropdownValues['Cor/Raca/Etnia'] as int? ?? 0;
    int escolaridadeValue =
        controller.dropdownValues['Escolaridade'] as int? ?? 0;

    try {
      const url =
          'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/Estudante';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "id": 0,
          "nome": nomeController.text,
          "cpf": cpfController.text,
          "rg": rgController.text,
          "email": emailController.text,
          "numeroMatricula": numeroMatriculaController.text,
          "dataMatricula": dataMatriculaController.text,
          "telefone": telefoneController.text,
          "dataNascimento": dataNascimentoController.text,
          "tituloEleitor": tituloEleitorController.text,
          "estadoCivil": estadoCivilValue,
          "nacionalidade": nacionalidadeValue,
          "corRacaEtnia": corRacaEtniaValue,
          "escolaridade": escolaridadeValue,
          "nomePai": nomePaiController.text,
          "nomeMae": nomeMaeController.text,
          "telefonePai": telefonePaiController.text,
          "telefoneMae": telefoneMaeController.text,
          "endereco": {
            "id": 0,
            "logradouro": logradouroController.text,
            "numero": numeroController.text,
            "bairro": bairroController.text,
            "cidade": cidadeController.text,
            "estado": estadoController.text,
            "cep": cepController.text
          },
          "turmaId": 0
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.show(context, 'Estudante Cadastrado com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
        return response;
      } else {
        print('Erro ao cadastrar faculdade: ${response.statusCode}');
        print('Detalhes: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      return null;
    }
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

  Widget _buildTextInput(
    String field, {
    bool enabled = true,
    bool disabled = false,
    EdgeInsets? customPadding,
  }) {
    String labelText = controller.fieldNames[field] ?? field;
    TextInputType keyboardType = controller.getKeyboardType(field);
    int? maxLength = controller.getMaxLength(field);

    TextEditingController fieldController;
    fieldController = controller.getMaskedController(field, "");

    switch (field) {
      case 'Nome':
        fieldController = nomeController;
        break;
      default:
        fieldController = TextEditingController();
    }

    return Padding(
      padding: customPadding ?? const EdgeInsets.only(bottom: 16),
      child: CustomInputTextCadastro(
        controller: fieldController,
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
                title: 'Dados do Estudante',
                icon: Icons.person,
                initiallyExpanded: isDadosEstudanteExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDadosEstudanteExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('NumeroMatricula'),
                  _buildTextInput('DataMatricula'),
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
                  _buildTextInput('TituloEleitor'),
                  _buildDropdown('EstadoCivil'),
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
                  _buildTextInput(
                    'NomePai',
                    disabled: naoConstaPai,
                  ),
                  _buildTextInput(
                    'TelefonePai',
                    disabled: naoConstaPai,
                    customPadding: const EdgeInsets.only(bottom: 0),
                  ),
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    value: naoConstaPai,
                    onChanged: (value) {
                      setState(() {
                        naoConstaPai = value ?? false;
                        if (naoConstaPai) {
                          controller.controllers['NomePai']?.clear();
                          controller.controllers['TelefonePai']?.clear();
                        }
                      });
                    },
                    title: const Text('Não consta'),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.buttonColor,
                  ),
                  _buildTextInput(
                    'NomeMae',
                    disabled: naoConstaMae,
                  ),
                  _buildTextInput(
                    'TelefoneMae',
                    disabled: naoConstaMae,
                    customPadding: const EdgeInsets.only(bottom: 0),
                  ),
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    value: naoConstaMae,
                    onChanged: (value) {
                      setState(() {
                        naoConstaMae = value ?? false;
                        if (naoConstaMae) {
                          controller.controllers['NomeMae']?.clear();
                          controller.controllers['TelefoneMae']?.clear();
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
                title: 'Curso',
                icon: Icons.library_books_rounded,
                initiallyExpanded: isCursoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isCursoExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('Nome'),
                  _buildTextInput('Turma'),
                  _buildTextInput('Periodo'),
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
                  _buildTextInput('EnderecoLogradouro'),
                  _buildTextInput('EnderecoNumero'),
                  _buildTextInput('EnderecoBairro'),
                  _buildTextInput('EnderecoCidade'),
                  _buildTextInput('EnderecoEstado'),
                  _buildTextInput('EnderecoCEP'),
                ],
              ),
              CustomButton(
                text: 'Cadastrar',
                onPressed: () {
                  cadastrarEstudante();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
