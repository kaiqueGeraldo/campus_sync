import 'dart:convert';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  bool _isLoading = false;
  Map<String, dynamic>? faculdadeSelecionada;
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
  List<DropdownMenuItem<int>> turmasDropdownItems = [];
  Map<int, List<dynamic>> turmasPorCurso = {};
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
    setState(() {
      _isLoading = true;
    });

    int? estadoCivilValue = controller.dropdownValues['EstadoCivil'];
    int? nacionalidadeValue = controller.dropdownValues['Nacionalidade'];
    int? corRacaEtniaValue = controller.dropdownValues['Cor/Raca/Etnia'];
    int? escolaridadeValue = controller.dropdownValues['Escolaridade'];
    int? turmaIdSelecionada = controller.dropdownValues['Turma'];
    String? dataMatricula = dataMatriculaController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').format(
            DateFormat('dd/MM/yyyy').parse(dataMatriculaController.text))
        : null;

    String? dataNascimento = dataNascimentoController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').format(
            DateFormat('dd/MM/yyyy').parse(dataNascimentoController.text))
        : null;

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
          "dataMatricula": dataMatricula,
          "telefone": telefoneController.text,
          "dataNascimento": dataNascimento,
          "tituloEleitor": tituloEleitorController.text,
          "estadoCivil": getEstadoCivilString(estadoCivilValue),
          "nacionalidade": getNacionalidadeString(nacionalidadeValue),
          "corRacaEtnia": getCorRacaEtniaString(corRacaEtniaValue),
          "escolaridade": getEscolaridadeString(escolaridadeValue),
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
          "turmaId": turmaIdSelecionada
        }),
      );

      print('TESTE DE CADASTRO: ${response.body}');
      print('TESTE DE CADASTRO: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.show(context, 'Estudante Cadastrado com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
        return response;
      } else {
        CustomSnackbar.show(context, response.body);
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? getEstadoCivilString(int? value) {
    switch (value) {
      case 0:
        return 'Solteiro';
      case 1:
        return 'Casado';
      case 2:
        return 'Divorciado';
      case 3:
        return 'Viúvo';
      default:
        return null;
    }
  }

  String? getNacionalidadeString(int? value) {
    switch (value) {
      case 0:
        return 'Brasileiro';
      case 1:
        return 'Estrangeiro';
      default:
        return null;
    }
  }

  String? getCorRacaEtniaString(int? value) {
    switch (value) {
      case 0:
        return 'Branco';
      case 1:
        return 'Pardo';
      case 2:
        return 'Negro';
      case 3:
        return 'Amarelo';
      case 4:
        return 'Indígena';
      default:
        return null;
    }
  }

  String? getEscolaridadeString(int? value) {
    switch (value) {
      case 0:
        return 'Ensino Médio';
      case 1:
        return 'Graduação';
      case 2:
        return 'Pós-Graduação';
      case 3:
        return 'Mestrado';
      case 4:
        return 'Doutorado';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: Center(
            child: CircularProgressIndicator(
          color: AppColors.buttonColor,
        )),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () {}, isLoading: false);
    }
    
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Cadastro de Estudantes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomExpansionCard(
                title: 'Dados do Estudante',
                icon: Icons.person,
                initiallyExpanded: isDadosEstudanteExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDadosEstudanteExpanded = expanded;
                  });
                },
                children: [
                  controller.buildTextInput(
                    'Nome',
                    context,
                    nomeController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'Email',
                    context,
                    emailController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'Telefone',
                    context,
                    telefoneController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'DataNascimento',
                    context,
                    dataNascimentoController,
                    !_isLoading,
                  ),
                ],
              ),
              CustomExpansionCard(
                title: 'Documentos',
                icon: Icons.file_copy,
                initiallyExpanded: isDocumentosExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDocumentosExpanded = expanded;
                  });
                },
                children: [
                  controller.buildTextInput(
                    'CPF',
                    context,
                    cpfController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'RG',
                    context,
                    rgController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'TituloEleitor',
                    context,
                    tituloEleitorController,
                    !_isLoading,
                  ),
                  controller.buildDropdown(
                    'EstadoCivil',
                    context,
                    !_isLoading,
                    (newValue) {
                      setState(() {
                        controller.dropdownValues['EstadoCivil'] = newValue;
                      });
                    },
                  ),
                  controller.buildDropdown(
                    'Nacionalidade',
                    context,
                    !_isLoading,
                    (newValue) {
                      setState(() {
                        controller.dropdownValues['Nacionalidade'] = newValue;
                      });
                    },
                  ),
                  controller.buildDropdown(
                    'Cor/Raca/Etnia',
                    context,
                    !_isLoading,
                    (newValue) {
                      setState(() {
                        controller.dropdownValues['Cor/Raca/Etnia'] = newValue;
                      });
                    },
                  ),
                  controller.buildDropdown(
                    'Escolaridade',
                    context,
                    !_isLoading,
                    (newValue) {
                      setState(() {
                        controller.dropdownValues['Escolaridade'] = newValue;
                      });
                    },
                  ),
                ],
              ),
              CustomExpansionCard(
                title: 'Informações dos Pais',
                icon: Icons.family_restroom,
                initiallyExpanded: isInformacoesPaisExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isInformacoesPaisExpanded = expanded;
                  });
                },
                children: [
                  controller.buildTextInput(
                    'NomePai',
                    context,
                    nomePaiController,
                    !_isLoading,
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
                        }
                      });
                    },
                    title: const Text('Não consta'),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.buttonColor,
                  ),
                  controller.buildTextInput(
                    'NomeMae',
                    context,
                    nomeMaeController,
                    !_isLoading,
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
                        }
                      });
                    },
                    title: const Text('Não consta'),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.buttonColor,
                  ),
                ],
              ),
              CustomExpansionCard(
                title: 'Curso',
                icon: Icons.library_books_rounded,
                initiallyExpanded: isCursoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isCursoExpanded = expanded;
                  });
                },
                children: [
                  controller.buildTextInput(
                    'NumeroMatricula',
                    context,
                    numeroMatriculaController,
                    !_isLoading,
                  ),
                  controller.buildFaculdadeInput(context),
                  ValueListenableBuilder<Map<String, dynamic>>(
                    valueListenable: controller.faculdadeSelecionadaNotifier,
                    builder: (context, faculdadeSelecionada, child) {
                      return Column(
                        children: [
                          if (faculdadeSelecionada.isNotEmpty)
                            controller.buildCursosDropdown(
                              context,
                              !_isLoading,
                            ),
                          ValueListenableBuilder<int?>(
                            valueListenable:
                                controller.cursoSelecionadoNotifier,
                            builder: (context, cursoSelecionado, child) {
                              final turmas =
                                  controller.turmasPorCurso[cursoSelecionado];

                              if (cursoSelecionado != null &&
                                  (turmas == null || turmas.isEmpty)) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  CustomSnackbar.show(
                                    context,
                                    'O curso selecionado não possui turmas associadas.',
                                  );
                                });
                              }

                              return Column(
                                children: [
                                  if (cursoSelecionado != null &&
                                      turmas != null &&
                                      turmas.isNotEmpty)
                                    controller.buildTurmasDropdown(
                                      context,
                                      !_isLoading,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  controller.buildTextInput(
                    'DataMatricula',
                    context,
                    dataMatriculaController,
                    !_isLoading,
                  ),
                ],
              ),
              CustomExpansionCard(
                title: 'Endereço',
                icon: Icons.home,
                initiallyExpanded: isEnderecoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isEnderecoExpanded = expanded;
                  });
                },
                children: [
                  controller.buildTextInput(
                    'EnderecoLogradouro',
                    context,
                    logradouroController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'EnderecoNumero',
                    context,
                    numeroController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'EnderecoBairro',
                    context,
                    bairroController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'EnderecoCidade',
                    context,
                    cidadeController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'EnderecoEstado',
                    context,
                    estadoController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'EnderecoCEP',
                    context,
                    cepController,
                    !_isLoading,
                  ),
                ],
              ),
              CustomButton(
                text: _isLoading ? '' : 'Cadastrar',
                isLoading: _isLoading,
                onPressed: () {
                  if (!_isLoading) {
                    cadastrarEstudante();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
