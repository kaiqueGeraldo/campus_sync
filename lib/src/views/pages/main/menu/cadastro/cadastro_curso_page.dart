import 'dart:convert';

import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/selecionar_faculdade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CadastroCursoPage extends StatefulWidget {
  final String endpoint;

  const CadastroCursoPage({
    super.key,
    required this.endpoint,
  });

  @override
  State<CadastroCursoPage> createState() => _CadastroCursoPageState();
}

class _CadastroCursoPageState extends State<CadastroCursoPage> {
  late CadastroController controller;
  Map<String, dynamic>? faculdadeSelecionada;
  bool isDadosCursoExpanded = true;
  final TextEditingController _disciplinasController = TextEditingController();
  final TextEditingController mensalidadeController = TextEditingController();
  List<String> cursosDisponiveis = [];
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
  List<TextEditingController> turmasNomeControllers = [];
  List<int?> turmasPeriodoValues = [];
  List<TextEditingController> turmasPeriodoControllers = [];
  List<String> disciplinasDisponiveis = [];
  final List<String> disciplinasOferecidos = [];
  List<String> filteredDisciplinas = [];

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
  }

  @override
  void dispose() {
    _disciplinasController.dispose();
    mensalidadeController.dispose();
    for (var controller in turmasNomeControllers) {
      controller.dispose();
    }
    for (var controller in turmasPeriodoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<http.Response?> cadastrarCurso() async {
    int quantidadeTurmasValue =
        controller.dropdownValues['Turmas'] as int? ?? 0;

    final mensalidade =
        int.parse(mensalidadeController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    // Gerar a lista de turmas com os valores corretos
    final turmas = List.generate(
      quantidadeTurmasValue,
      (index) {
        return {
          "id": 0,
          "nome": turmasNomeControllers[index].text,
          "periodo": turmasPeriodoValues[index] ?? 0, // Atualizado
        };
      },
    );

    // Buscar o ID e nome do curso selecionado no dropdown
    int? cursoId;
    String nomeCurso = '';
    if (controller.dropdownValues['Curso'] != null) {
      final cursoSelecionado = cursosDropdownItems.firstWhere(
        (item) => item.value == controller.dropdownValues['Curso'],
        orElse: () => const DropdownMenuItem<int>(
          value: -1,
          child: Text('Curso não encontrado'),
        ),
      );
      if (cursoSelecionado.value != -1) {
        cursoId = cursoSelecionado.value;
        nomeCurso = (cursoSelecionado.child as Text).data ?? ''; // Atualizado
      } else {
        CustomSnackbar.show(context, 'Curso não encontrado');
        return null;
      }
    }

    if (cursoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um curso antes de continuar.'),
        ),
      );
      return null;
    }

    if (faculdadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, selecione uma faculdade antes de continuar.'),
        ),
      );
      return null;
    }

    if (mensalidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha a mensalidade.'),
        ),
      );
      return null;
    }

    try {
      // Adicionando o ID do curso na URL
      final url =
          'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/Curso/$cursoId';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "nome": nomeCurso,
          "mensalidade": mensalidade,
          "faculdadeId": faculdadeSelecionada?['id'] ?? 0,
          "quantidadeTurmas": quantidadeTurmasValue,
          "turmas": turmas,
          "disciplinas": disciplinasOferecidos,
        }),
      );

      if (response.statusCode == 204) {
        CustomSnackbar.show(context, 'Curso Cadastrado com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
        return response;
      } else {
        print('Erro ao cadastrar curso: ${response.statusCode}');
        print('Detalhes: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao cadastrar curso. Código: ${response.statusCode}. Verifique os dados.'),
          ),
        );
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erro de conexão com a API. Tente novamente mais tarde.'),
        ),
      );
      return null;
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

// Construtor dos campos de turmas
  Widget _buildTurmasInputs() {
    final quantidadeTurmas = controller.dropdownValues['Turmas'] as int? ?? 0;

    if (turmasNomeControllers.length != quantidadeTurmas ||
        turmasPeriodoValues.length != quantidadeTurmas) {
      atualizarControllers(quantidadeTurmas);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(quantidadeTurmas, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Turma ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomInputTextCadastro(
              controller: turmasNomeControllers[index],
              labelText: 'Nome da Turma',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 5),
            _buildPeriodoDropdown(index),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

// Dropdown para período específico da turma
  Widget _buildPeriodoDropdown(int index) {
    final List<int> valoresUtilizados = turmasPeriodoValues
        .where((valor) => valor != null)
        .cast<int>()
        .toList();

    final List<DropdownMenuItem<int>> items = const [
      DropdownMenuItem(value: 0, child: Text('Matutino')),
      DropdownMenuItem(value: 1, child: Text('Vespertino')),
      DropdownMenuItem(value: 2, child: Text('Noturno')),
      DropdownMenuItem(value: 3, child: Text('Integral')),
    ]
        .where((item) =>
            !valoresUtilizados.contains(item.value) ||
            item.value == turmasPeriodoValues[index])
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: turmasPeriodoValues[index],
        items: items,
        onChanged: (newValue) {
          setState(() {
            turmasPeriodoValues[index] = newValue;
            print('Período da turma ${index + 1} atualizado para $newValue');
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

  void abrirTelaFaculdades() async {
    try {
      final faculdades = (await ApiService().listarFaculdades())
          .map((faculdade) => faculdade as Map<String, dynamic>)
          .toList();

      final selecionada = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => SelecionarFaculdadePage(
            faculdades: faculdades,
            onSelecionar: (faculdade) {
              Navigator.pop(context, faculdade);
            },
          ),
        ),
      );

      if (selecionada != null) {
        setState(() {
          faculdadeSelecionada = selecionada;
        });

        final cursos = await ApiService().buscarCursosPorFaculdade(
          faculdadeSelecionada!['id'],
        );

        setState(() {
          controller.dropdownValues['Curso'] = null;
          cursosDropdownItems = cursos.map((curso) {
            return DropdownMenuItem<int>(
              value: curso['id'],
              child: Text(curso['nome']),
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Erro ao buscar faculdades ou cursos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erro ao carregar faculdades ou cursos. Tente novamente.'),
        ),
      );
    }
  }

  Widget _buildFaculdadeInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: abrirTelaFaculdades,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    faculdadeSelecionada != null
                        ? faculdadeSelecionada!['nome']
                        : 'Selecione uma Faculdade',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (faculdadeSelecionada != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          faculdadeSelecionada = null;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ],
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

  Future<List<Map<String, dynamic>>> getCursosPorFaculdade(
      int faculdadeId) async {
    try {
      final response = await ApiService().buscarCursosPorFaculdade(faculdadeId);
      return (response).map((curso) => curso as Map<String, dynamic>).toList();
    } catch (e) {
      print('Erro ao buscar cursos para faculdade $faculdadeId: $e');
      return [];
    }
  }

  Widget _buildDropdown(String field) {
    List<DropdownMenuItem<int>> items = [];

    if (field == 'Curso') {
      items = cursosDropdownItems;
    } else {
      items = controller.getDropdownItems(field);
    }

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
          labelText: controller.fieldNames[field] ?? field,
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

    TextInputFormatter? inputFormatter;
    if (field == 'Mensalidade') {
      inputFormatter = _currencyFormatter();
    }

    TextEditingController fieldController;
    fieldController = controller.getMaskedController(field, "");

    switch (field) {
      case 'Mensalidade':
        fieldController = mensalidadeController;
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
        inputFormatters: inputFormatter != null ? [inputFormatter] : null,
      ),
    );
  }

  TextInputFormatter _currencyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (newText.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      double value = double.tryParse(newText) ?? 0;
      String formatted = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(value / 100);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  Widget _buildDisciplinasInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _disciplinasController,
          onChanged: _filterDisciplinas,
          decoration: InputDecoration(
            labelText: 'Adicionar Disciplina',
            floatingLabelStyle:
                const TextStyle(color: AppColors.backgroundBlueColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.backgroundBlueColor),
            ),
          ),
        ),
        if (_disciplinasController.text.isNotEmpty &&
            filteredDisciplinas.isNotEmpty)
          Card(
            color: AppColors.backgroundWhiteColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8))),
            margin: const EdgeInsets.only(top: 5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredDisciplinas.length,
                itemBuilder: (context, index) {
                  final curso = filteredDisciplinas[index];
                  return ListTile(
                    title: Text(curso),
                    onTap: () => _addDisciplina(curso),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDisciplinasOferecidos() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disciplinas Oferecidos:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: disciplinasOferecidos.map((curso) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 110,
                ),
                child: Chip(
                  label: GestureDetector(
                    onTap: () {
                      CustomSnackbar.show(
                        context,
                        curso,
                        backgroundColor: AppColors.socialButtonColor,
                      );
                    },
                    child: Text(
                      curso,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  backgroundColor: AppColors.lightGreyColor,
                  deleteIcon: const Icon(Icons.close, color: Colors.red),
                  onDeleted: () => _removeDisciplina(curso),
                ),
              );
            }).toList(),
          ),
          if (disciplinasDisponiveis.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _removeAllDisciplina,
                child: const Text('Remover tudo',
                    style: TextStyle(color: AppColors.buttonColor)),
              ),
            )
        ],
      ),
    );
  }

  void _addDisciplina(String curso) {
    setState(() {
      if (!disciplinasOferecidos.contains(curso)) {
        disciplinasOferecidos.add(curso);
      }
      _disciplinasController.clear();
      filteredDisciplinas.clear();
    });
  }

  void _removeDisciplina(String curso) {
    setState(() {
      disciplinasOferecidos.remove(curso);
    });
  }

  void _removeAllDisciplina() {
    customShowDialog(
        context: context,
        title: 'Confirmar Exclusão',
        content: 'Tem certeza que deseja remover todos os itens da lista?',
        cancelText: 'Não',
        onCancel: () => Navigator.pop(context),
        confirmText: 'Sim',
        onConfirm: () {
          setState(() {
            disciplinasOferecidos.clear();
          });
          Navigator.pop(context);
        });
  }

  void _filterDisciplinas(String query) {
    setState(() {
      filteredDisciplinas = disciplinasDisponiveis
          .where((curso) => curso.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Cadastro de Curso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                title: 'Dados do Curso',
                icon: Icons.library_books,
                initiallyExpanded: isDadosCursoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDadosCursoExpanded = expanded;
                  });
                },
                children: [
                  _buildFaculdadeInput(),
                  _buildDropdown('Curso'),
                  _buildTextInput('Mensalidade'),
                  _buildDisciplinasInput(),
                  if (disciplinasOferecidos.isNotEmpty)
                    _buildDisciplinasOferecidos(),
                ],
              ),
              _buildCard(
                title: 'Turmas',
                icon: Icons.switch_account_outlined,
                initiallyExpanded: isDadosCursoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDadosCursoExpanded = expanded;
                  });
                },
                children: [
                  _buildDropdown('Turmas'),
                  _buildTurmasInputs(),
                ],
              ),
              CustomButton(
                text: 'Cadastrar',
                onPressed: () {
                  cadastrarCurso();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
