import 'dart:convert';

import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdicionarTurmasPage extends StatefulWidget {
  const AdicionarTurmasPage({super.key});

  @override
  State<AdicionarTurmasPage> createState() => _AdicionarTurmasPageState();
}

class _AdicionarTurmasPageState extends State<AdicionarTurmasPage> {
  late CadastroController controller;
  final GlobalKey<FormState> turmasFormKey = GlobalKey<FormState>();
  String cursosError = '';
  late Future<int> quantidadeTurmasExistentes;
  Map<String, dynamic>? curso;
  final TextEditingController turmasController = TextEditingController();
  List<String> cursosDisponiveis = [];
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
  List<TextEditingController> turmasNomeControllers = [];
  List<int?> turmasPeriodoValues = [];
  List<TextEditingController> turmasPeriodoControllers = [];

  bool _isLoading = false;
  bool isTurmasExpanded = true;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    controller.dropdownValues['Turmas'] = 0;
  }

  @override
  void dispose() {
    for (var controller in turmasNomeControllers) {
      controller.dispose();
    }
    for (var controller in turmasPeriodoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<http.Response?> atualizarTurma() async {
    final isTurmasDadosValid = turmasFormKey.currentState?.validate() ?? false;

    //final hasCourses = cursosOferecidos.isNotEmpty;

    // setState(() {
    //   cursosError = (hasCourses ? null : 'Adicione ao menos um item!')!;
    // });

    if (!isTurmasDadosValid /*|| !hasCourses*/) {
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    int quantidadeTurmasValue =
        controller.dropdownValues['Turmas'] as int? ?? 0;

    final turmas = List.generate(
      quantidadeTurmasValue,
      (index) {
        return {
          "id": 0,
          "nome": turmasNomeControllers[index].text,
          "periodo": turmasPeriodoValues[index] ?? 0,
        };
      },
    );

    if (controller.faculdadeSelecionadaNotifier.value.isEmpty) {
      CustomSnackbar.show(
        context,
        'Por favor, selecione uma faculdade antes de continuar.',
        backgroundColor: AppColors.darkGreyColor,
      );
      return null;
    }

    int? cursoId = curso?['id'];
    if (cursoId != null) {
      final cursoSelecionado =
          controller.cursosDropdownItemsNotifier.value.firstWhere(
        (item) => item.value == cursoId,
        orElse: () => const DropdownMenuItem<int>(
          value: -1,
          child: Text('Curso não encontrado'),
        ),
      );

      if (cursoSelecionado.value != -1) {
      } else {
        CustomSnackbar.show(context, 'Curso selecionado não encontrado.');
        return null;
      }
    } else {
      CustomSnackbar.show(
        context,
        'Por favor, selecione um curso antes de continuar.',
        backgroundColor: AppColors.darkGreyColor,
      );
      return null;
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/Curso/$cursoId/turmas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(turmas),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        CustomSnackbar.show(context, 'Turma atualizada com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
        return response;
      } else {
        print('Erro ao adicionar turma(s): ${response.statusCode}');
        print('Detalhes: ${response.body}');
        CustomSnackbar.show(context,
            'Erro ao adicionar turma(s). Código: ${response.statusCode}. Verifique os dados.');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      CustomSnackbar.show(
          context, 'Erro de conexão com a API. Tente novamente mais tarde.');
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para atualizar controllers e valores de períodos com base no valor do dropdown
  void atualizarControllers(int novaQuantidade) {
    setState(() {
      turmasNomeControllers =
          List.generate(novaQuantidade, (index) => TextEditingController());
      turmasPeriodoValues = List.generate(novaQuantidade, (index) => null);
    });
  }

  // Dropdown para quantidade de turmas
  Widget buildDropdownQuantidade(int quantidadeExistente) {
    const maxTurmas = 4;
    final quantidadeDisponivel = maxTurmas - quantidadeExistente;

    final dropdownItems = List.generate(
      quantidadeDisponivel + 1,
      (index) => DropdownMenuItem(
        value: index,
        child: Text('$index'),
      ),
    );

    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          value: dropdownItems.any(
                  (item) => item.value == controller.dropdownValues['Turmas'])
              ? controller.dropdownValues['Turmas']
              : null,
          items: dropdownItems,
          onChanged: (newValue) {
            setState(() {
              controller.dropdownValues['Turmas'] = newValue;
              atualizarControllers(newValue!);
            });
          },
          decoration: const InputDecoration(
            labelText: 'Quantidade de Turmas',
            labelStyle: TextStyle(color: AppColors.backgroundBlueColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: AppColors.backgroundBlueColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: AppColors.lightGreyColor,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ));
  }

  // Construtor dos campos de turmas
  Widget _buildTurmasInputs() {
    final quantidadeTurmas = controller.dropdownValues['Turmas'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(quantidadeTurmas, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Turma ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CustomInputTextCadastro(
              controller: turmasNomeControllers[index],
              labelText: 'Nome da Turma',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            _buildPeriodoDropdown(index),
          ],
        );
      }),
    );
  }

  // Dropdown para período específico da turma
  Widget _buildPeriodoDropdown(int index) {
    if (curso == null) {
      return const Text('Carregando períodos...');
    }

    // Obter os períodos já cadastrados para o curso atual a partir de `turmas`
    final List<int> periodosCadastrados =
        curso!['turmas'].map<int>((turma) => turma['periodo'] as int).toList();

    // Adicionar os períodos já selecionados em outras turmas
    for (int i = 0; i < turmasPeriodoValues.length; i++) {
      if (i != index && turmasPeriodoValues[i] != null) {
        periodosCadastrados.add(turmasPeriodoValues[i]!);
      }
    }

    // Lista completa de períodos
    final List<DropdownMenuItem<int>> todosPeriodos = [
      const DropdownMenuItem(value: 0, child: Text('Matutino')),
      const DropdownMenuItem(value: 1, child: Text('Vespertino')),
      const DropdownMenuItem(value: 2, child: Text('Noturno')),
      const DropdownMenuItem(value: 3, child: Text('Integral')),
    ];

    // Excluir períodos já cadastrados
    final List<DropdownMenuItem<int>> items = todosPeriodos
        .where((item) => !periodosCadastrados.contains(item.value))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: turmasPeriodoValues[index],
        items: items,
        onChanged: (newValue) {
          setState(() {
            turmasPeriodoValues[index] = newValue;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Período',
          labelStyle: TextStyle(color: AppColors.backgroundBlueColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: AppColors.backgroundBlueColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        dropdownColor: AppColors.lightGreyColor,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        validator: (value) {
          if (value == null) {
            return 'Por favor, selecione um período';
          }
          return null;
        },
      ),
    );
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

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) {
          print('Navegação permitida.');
        } else {
          CustomSnackbar.show(
            context,
            'Navegação bloqueada! Aguarde o carregamento.',
            duration: const Duration(seconds: 2),
          );
          print('Tentativa de navegação bloqueada.');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                CustomExpansionCard(
                  formKey: turmasFormKey,
                  title: 'Adicionar Turmas',
                  icon: Icons.people_rounded,
                  initiallyExpanded: true,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isTurmasExpanded = expanded;
                    });
                  },
                  children: [
                    controller.buildFaculdadeInput(context),
                    ValueListenableBuilder<Map>(
                      valueListenable: controller.faculdadeSelecionadaNotifier,
                      builder: (context, faculdadeSelecionada, child) {
                        if (faculdadeSelecionada.isNotEmpty) {
                          return controller.buildCursosDropdown(
                              context, !_isLoading);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    ValueListenableBuilder<int?>(
                      valueListenable: controller.cursoSelecionadoNotifier,
                      builder: (context, cursoSelecionado, child) {
                        if (cursoSelecionado != null) {
                          if (controller.cursoSelecionadoNotifier.value !=
                                  null &&
                              !cursosDropdownItems.any((item) =>
                                  item.value ==
                                  controller.cursoSelecionadoNotifier.value)) {
                            controller.cursoSelecionadoNotifier.value = null;
                          }

                          return FutureBuilder<Map<String, dynamic>>(
                            future: ApiService()
                                .buscarTurmasPorCurso(cursoSelecionado),
                            builder: (context, snapshot) {
                              print('RETORNO: ${snapshot.data}');
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.buttonColor,
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Erro: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                final data = snapshot.data!;
                                final quantidadeExistente =
                                    data['quantidadeTurmas'] ?? 0;

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  curso = data;
                                  final List<int> periodosCadastrados = (data[
                                          'turmas'] as List)
                                      .map((turma) => turma['periodo'] as int)
                                      .toList();
                                  if (turmasPeriodoValues.isEmpty) {
                                    turmasPeriodoValues = periodosCadastrados;
                                  }

                                  if (curso?['quantidadeTurmas'] == 4) {
                                    CustomSnackbar.show(
                                      context,
                                      'Esse curso atingiu o número máximo de turmas!',
                                      duration: const Duration(seconds: 2),
                                    );
                                  }

                                  // Ajuste aqui: Verifica e ajusta o valor do dropdown
                                  const maxTurmas = 4;
                                  final quantidadeDisponivel =
                                      (maxTurmas - quantidadeExistente)
                                          .clamp(0, maxTurmas);

                                  if (controller.dropdownValues['Turmas']! >
                                      quantidadeDisponivel) {
                                    setState(() {
                                      controller.dropdownValues['Turmas'] =
                                          quantidadeDisponivel;
                                      atualizarControllers(
                                          quantidadeDisponivel as int);
                                    });
                                  }
                                });

                                return Column(
                                  children: [
                                    buildDropdownQuantidade(
                                        quantidadeExistente),
                                    if (controller.dropdownValues['Turmas'] !=
                                            null &&
                                        controller.dropdownValues['Turmas']! >
                                            0)
                                      _buildTurmasInputs(),
                                  ],
                                );
                              } else {
                                return const Text('Nenhuma turma encontrada.');
                              }
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                CustomButton(
                  text: 'Atualizar',
                  isLoading: _isLoading,
                  onPressed: atualizarTurma,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
