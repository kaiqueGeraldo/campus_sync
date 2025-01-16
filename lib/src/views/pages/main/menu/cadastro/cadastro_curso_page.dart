import 'dart:convert';

import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
  final GlobalKey<FormState> cursoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> turmasFormKey = GlobalKey<FormState>();
  String cadastroError = '';
  bool _isButtonClicked = false;
  bool _isLoading = false;
  Map<String, dynamic>? faculdadeSelecionada;
  bool isDadosCursoExpanded = true;
  final TextEditingController _disciplinasController = TextEditingController();
  final TextEditingController mensalidadeController = TextEditingController();
  List<String> cursosDisponiveis = [];
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
  List<TextEditingController> turmasNomeControllers = [];
  List<int?> turmasPeriodoValues = [];
  List<TextEditingController> turmasPeriodoControllers = [];
  final List<String> disciplinasOferecidos = [];
  List<String> filteredDisciplinas = [];
  List<String> disciplinasDisponiveis = [
    "Matemática Básica",
    "Cálculo Diferencial e Integral",
    "Álgebra Linear",
    "Física Geral",
    "Química Geral",
    "Geometria Analítica",
    "Estatística Aplicada",
    "Engenharia de Software",
    "Inteligência Artificial",
    "Algoritmos e Estruturas de Dados",
    "Redes de Computadores",
    "Banco de Dados",
    "Ciência de Dados",
    "Internet das Coisas (IoT)",
    "Segurança da Informação",
    "Sistemas Embarcados",
    "Análise de Circuitos Elétricos",
    "Processamento de Sinais",
    "Desenvolvimento Mobile",
    "Desenvolvimento Web",
    "Filosofia",
    "Sociologia",
    "Antropologia",
    "Psicologia Geral",
    "História do Brasil",
    "História Mundial",
    "Geografia Humana",
    "Direitos Humanos",
    "Políticas Públicas",
    "Educação e Sociedade",
    "Teoria da Comunicação",
    "Ética e Cidadania",
    "Psicologia Organizacional",
    "História da Arte",
    "Pedagogia Aplicada",
    "Biologia Celular",
    "Genética",
    "Ecologia",
    "Fisiologia Humana",
    "Anatomia Humana",
    "Microbiologia",
    "Imunologia",
    "Farmacologia",
    "Bioquímica",
    "Enfermagem Básica",
    "Saúde Pública",
    "Nutrição e Metabolismo",
    "Higiene e Saúde",
    "Epidemiologia",
    "Psicologia da Saúde",
    "Educação Física e Esporte",
    "Direito Constitucional",
    "Direito Penal",
    "Administração Geral",
    "Gestão de Projetos",
    "Marketing Digital",
    "Finanças Corporativas",
    "Contabilidade Básica",
    "Economia",
    "Planejamento Urbano",
    "Ciências Políticas",
    "Comportamento Organizacional",
    "Empreendedorismo",
    "Relações Internacionais",
    "Ciência Atuária",
    "Linguagem e Comunicação",
    "Produção Audiovisual",
    "Fotografia",
    "Design Gráfico",
    "Design de Interiores",
    "Publicidade e Propaganda",
    "Jornalismo Investigativo",
    "Literatura Brasileira",
    "Teatro e Expressão Corporal",
    "Música e Ritmos",
    "História da Música",
    "Cinema e Produção Audiovisual",
    "Agronomia",
    "Engenharia Ambiental",
    "Gestão de Recursos Hídricos",
    "Manejo Florestal",
    "Climatologia",
    "Zootecnia",
    "Produção de Alimentos",
    "Sustentabilidade e Meio Ambiente",
    "Geoprocessamento",
    "Lógica e Raciocínio",
    "Libras",
    "Língua Inglesa",
    "Língua Espanhola",
    "Metodologia de Pesquisa",
    "Técnicas de Apresentação",
    "Estudos de Gênero",
    "Cultura e Sociedade"
  ];

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
    final isCursoValid = cursoFormKey.currentState?.validate() ?? false;
    final isTurmasValid = turmasFormKey.currentState?.validate() ?? false;

    if (!isCursoValid || !isTurmasValid) {
      return null;
    }
    print('disciplinas: $disciplinasOferecidos');
    setState(() {
      _isLoading = true;
    });

    int quantidadeTurmasValue =
        controller.dropdownValues['Turmas'] as int? ?? 0;

    final mensalidade =
        int.parse(mensalidadeController.text.replaceAll(RegExp(r'[^0-9]'), ''));

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

    final disciplinas = disciplinasOferecidos.map((disciplina) {
      return {
        "id": 0,
        "nome": disciplina,
        "descricao": '',
      };
    }).toList();

    int? cursoId = controller.cursoSelecionadoNotifier.value;
    String nomeCurso = '';
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
        nomeCurso = (cursoSelecionado.child as Text).data ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Curso selecionado não encontrado.'),
          ),
        );
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um curso antes de continuar.'),
        ),
      );
      return null;
    }

    if (controller.faculdadeSelecionadaNotifier.value.isEmpty) {
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
          "faculdadeId":
              controller.faculdadeSelecionadaNotifier.value['id'] ?? 0,
          "quantidadeTurmas": quantidadeTurmasValue,
          "turmas": turmas,
          "disciplinas": disciplinas,
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

  Widget _buildDisciplinasInput() {
    return controller.buildListInput(
      context,
      label: 'Adicionar Disciplina',
      enabled: !_isLoading,
      controller: _disciplinasController,
      itemsDisponiveis: disciplinasDisponiveis,
      filteredItems: filteredDisciplinas,
      onAddItem: _addDisciplina,
      onRemoveItem: _removeDisciplina,
      onRemoveAll: _removeAllDisciplina,
      onFilter: _filterDisciplinas,
    );
  }

  Widget _buildDisciplinasOferecidos() {
    return controller.buildSelectedItems(
      context,
      label: 'Disciplinas Oferecidas:',
      itemsSelecionados: disciplinasOferecidos,
      onRemoveItem: (disciplina) => _removeDisciplina(disciplina),
      onRemoveAll: _removeAllDisciplina,
    );
  }

  void _addDisciplina(String disciplina) {
    setState(() {
      if (!disciplinasOferecidos.contains(disciplina)) {
        disciplinasOferecidos.add(disciplina);
      }
      _disciplinasController.clear();
      filteredDisciplinas.clear();
    });
  }

  void _removeDisciplina(String disicplina) {
    setState(() {
      disciplinasOferecidos.remove(disicplina);
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
          .where((disciplina) =>
              disciplina.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
        appBar: AppBar(
          title: const Text('Cadastro de Cursos'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomExpansionCard(
                  formKey: cursoFormKey,
                  title: 'Dados do Curso',
                  icon: Icons.library_books,
                  initiallyExpanded: isDadosCursoExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDadosCursoExpanded = expanded;
                    });
                  },
                  children: [
                    if (!_isLoading)
                      controller.buildCamposFaculdadeECurso(
                          context, _isLoading),
                    controller.buildTextInput(
                      'Mensalidade',
                      context,
                      mensalidadeController,
                      !_isLoading,
                    ),
                    _buildDisciplinasInput(),
                    if (disciplinasOferecidos.isNotEmpty)
                      _buildDisciplinasOferecidos(),
                  ],
                ),
                CustomExpansionCard(
                  formKey: turmasFormKey,
                  title: 'Turmas',
                  icon: Icons.switch_account_outlined,
                  initiallyExpanded: isDadosCursoExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDadosCursoExpanded = expanded;
                    });
                  },
                  children: [
                    controller.buildDropdown(
                      'Turmas',
                      context,
                      !_isLoading,
                      (newValue) {
                        setState(() {
                          controller.dropdownValues['Turmas'] = newValue;
                        });
                      },
                    ),
                    _buildTurmasInputs(),
                  ],
                ),
                CustomButton(
                  text: _isLoading ? '' : 'Cadastrar',
                  isLoading: _isLoading,
                  onPressed: () {
                    if (!_isLoading) {
                      setState(() {
                        _isButtonClicked = true;
                      });
                      cadastrarCurso();
                    }
                  },
                ),
                const SizedBox(height: 15),
                if (_isButtonClicked && cadastroError.isNotEmpty)
                  Text(
                    cadastroError,
                    style: TextStyle(color: Colors.red[900], fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
