import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/selecionar_faculdade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  Map<String, dynamic>? faculdadeSelecionada;
  bool isDadosCursoExpanded = true;
  final TextEditingController _disciplinasController = TextEditingController();
  final List<String> disciplinasOferecidos = [];
  List<String> filteredDisciplinas = [];

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    controller.initControllers(widget.initialData);
  }

  String? cursoSelecionado;
  String? disciplinaSelecionada;

  final Map<String, List<String>> faculdadesDisponiveis = {
    "Faculdade A": ["Matemática", "Física"],
    "Faculdade B": ["Química", "Biologia"],
  };

  final Map<String, List<String>> cursosEDisciplinas = {
    "Matemática": ["Geometria Plana", "Geometria Espacial", "Álgebra Linear"],
    "Física": ["Mecânica", "Eletromagnetismo", "Termodinâmica"],
    "Química": ["Química Orgânica", "Química Inorgânica", "Química Analítica"],
    "Biologia": ["Genética", "Microbiologia", "Fisiologia"],
  };

  List<String> cursosDisponiveis = [];
  List<String> disciplinasDisponiveis = [];

  // Atualiza os cursos disponíveis com base na faculdade selecionada
  void atualizarCursos(String? faculdade) {
    setState(() {
      cursosDisponiveis =
          faculdade != null ? faculdadesDisponiveis[faculdade]! : [];
      cursoSelecionado = null; // Reseta a seleção de curso
      disciplinasDisponiveis = []; // Reseta a lista de disciplinas
    });
  }

  // Atualiza as disciplinas disponíveis com base no curso selecionado
  void atualizarDisciplinas(String? curso) {
    setState(() {
      disciplinasDisponiveis = curso != null ? cursosEDisciplinas[curso]! : [];
      disciplinaSelecionada = null; // Reseta a seleção de disciplina
    });
  }

  void abrirTelaFaculdades() async {
    try {
      // Aguarda os dados vindos da API
      final faculdades = (await ApiService().listarFaculdades())
          .map((faculdade) => faculdade as Map<String, dynamic>)
          .toList();

      // Certifica-se de que a lista é do tipo esperado
      final selecionada = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => SelecionarFaculdadePage(
            faculdades: faculdades,
            onSelecionar: (faculdade) {
              setState(() {
                faculdadeSelecionada = faculdade;
              });
            },
          ),
        ),
      );

      if (selecionada != null) {
        setState(() {
          faculdadeSelecionada = selecionada;
        });
      }
    } catch (e) {
      // Exibe um erro caso algo dê errado
      print('Erro ao buscar faculdades: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro ao carregar faculdades. Tente novamente.')),
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
                        : 'Faculdade',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
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

  Widget _buildDropdown(String field) {
    List<DropdownMenuItem<int>> items = controller.getDropdownItems(field);
    String labelText = controller.fieldNames[field] ?? field;

    // if (field == 'Curso') {
    //   items = controller.getDropdownItems(
    //     faculdadeSelecionada?['id'] ?? -1,
    //   );
    // } else {
    //   items = controller.getDropdownItems(field);
    // }

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

    TextInputFormatter? inputFormatter;
    if (field == 'Valor') {
      inputFormatter = _currencyFormatter();
    }

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
                  ...controller.controllers.keys.map(_buildTextInput),
                  ...controller.dropdownValues.keys.map(_buildDropdown),
                  _buildDisciplinasInput(),
                  if (disciplinasOferecidos.isNotEmpty)
                    _buildDisciplinasOferecidos(),
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
                    if (faculdadeSelecionada != null) {
                      controller.controllers['FaculdadeId']?.text =
                          faculdadeSelecionada!['id'].toString();
                    }
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
      ),
    );
  }
}
