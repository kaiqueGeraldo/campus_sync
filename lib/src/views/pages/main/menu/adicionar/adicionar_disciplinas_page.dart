import 'dart:convert';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdicionarDisciplinasPage extends StatefulWidget {
  const AdicionarDisciplinasPage({super.key});

  @override
  State<AdicionarDisciplinasPage> createState() =>
      _AdicionarDisciplinasPageState();
}

class _AdicionarDisciplinasPageState extends State<AdicionarDisciplinasPage> {
  late CadastroController controller;
  final GlobalKey<FormState> disciplinasFormKey = GlobalKey<FormState>();
  String cursosError = '';
  Map<String, dynamic>? curso;
  final TextEditingController disciplinasController = TextEditingController();
  List<String> cursosDisponiveis = [];
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
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

  bool _isLoading = false;
  bool isDisciplinasExpanded = true;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
  }

  Future<http.Response?> atualizarDisciplinas() async {
    final isDisciplinasDadosValid =
        disciplinasFormKey.currentState?.validate() ?? false;

    //final hasCourses = cursosOferecidos.isNotEmpty;

    // setState(() {
    //   cursosError = (hasCourses ? null : 'Adicione ao menos um item!')!;
    // });

    if (!isDisciplinasDadosValid /*|| !hasCourses*/) {
      return null;
    }
    final disciplinas = disciplinasOferecidos.map((disciplina) {
      return {
        "id": 0,
        "nome": disciplina,
        "descricao": '',
      };
    }).toList();

    if (controller.faculdadeSelecionadaNotifier.value.isEmpty) {
      CustomSnackbar.show(
        context,
        'Por favor, selecione uma faculdade antes de continuar.',
        backgroundColor: AppColors.darkGreyColor,
      );
      return null;
    }

    int? cursoId = controller.cursoSelecionadoNotifier.value;
    if (cursoId != null) {
      final cursoSelecionado =
          controller.cursosDropdownItemsNotifier.value.firstWhere(
        (item) => item.value == cursoId,
        orElse: () => const DropdownMenuItem<int>(
          value: -1,
          child: Text('Curso não encontrado'),
        ),
      );

      if (cursoSelecionado.value == -1) {
        CustomSnackbar.show(context, 'Curso selecionado não encontrado.');
        return null;
      }
    } else {
      CustomSnackbar.show(
          context, 'Por favor, selecione um curso antes de continuar.');
      return null;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final disciplinasExistentes =
          await ApiService().buscarDisciplinasPorCurso(cursoId);

      List<String> disciplinasDuplicadas = [];
      List<Map<String, dynamic>> disciplinasParaAdicionar = [];

      final nomesDisciplinasExistentes = disciplinasExistentes
          .map((disciplina) => disciplina['nome'] as String)
          .toList();

      for (var disciplina in disciplinas) {
        final nomeDisciplina = disciplina['nome'];

        if (nomeDisciplina is String) {
          if (nomesDisciplinasExistentes.contains(nomeDisciplina)) {
            disciplinasDuplicadas.add(nomeDisciplina);
          } else {
            disciplinasParaAdicionar.add(disciplina);
          }
        } else {
          print('Nome da disciplina inválido: $nomeDisciplina');
        }
      }

      if (disciplinasDuplicadas.isNotEmpty) {
        final duplicadasMensagem = disciplinasDuplicadas.join(', ');
        customShowDialog(
          context: context,
          title: 'Disciplinas Duplicadas',
          content:
              'Os seguintes campos já estavam cadastrados no curso: $duplicadasMensagem.\nOs demais foram adicionados com sucesso.',
          confirmText: 'OK',
          onConfirm: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }

      // Enviar as disciplinas restantes para o backend
      if (disciplinasParaAdicionar.isNotEmpty) {
        final response = await http.put(
          Uri.parse('${ApiService.baseUrl}/Curso/$cursoId/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(disciplinasParaAdicionar),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (disciplinasDuplicadas.isNotEmpty) {
          } else {
            CustomSnackbar.show(context, 'Disciplinas atualizadas com sucesso!',
                backgroundColor: AppColors.successColor);
            Navigator.pop(context);
          }
          return response;
        } else {
          print('Erro ao adicionar disciplinas: ${response.statusCode}');
          print('Detalhes: ${response.body}');
          CustomSnackbar.show(context,
              'Erro ao adicionar disciplinas. Código: ${response.statusCode}. Verifique os dados.');
          return null;
        }
      } else {
        CustomSnackbar.show(
            context, 'Não há novas disciplinas para adicionar.');
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
    return null;
  }

  Widget _buildDisciplinasInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: controller.buildListInput(
        context,
        label: 'Adicionar Disciplina',
        enabled: !_isLoading,
        controller: disciplinasController,
        itemsDisponiveis: disciplinasDisponiveis,
        filteredItems: filteredDisciplinas,
        onAddItem: _addDisciplina,
        onRemoveItem: _removeDisciplina,
        onRemoveAll: _removeAllDisciplina,
        onFilter: _filterDisciplinas,
      ),
    );
  }

  Widget _buildDisciplinasOferecidos() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: controller.buildSelectedItems(
        context,
        label: 'Disciplinas Oferecidas:',
        itemsSelecionados: disciplinasOferecidos,
        onRemoveItem: (disciplina) => _removeDisciplina(disciplina),
        onRemoveAll: _removeAllDisciplina,
      ),
    );
  }

  void _addDisciplina(String disciplina) {
    setState(() {
      if (!disciplinasOferecidos.contains(disciplina)) {
        disciplinasOferecidos.add(disciplina);
      }
      disciplinasController.clear();
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                CustomExpansionCard(
                  formKey: disciplinasFormKey,
                  title: 'Adicionar Disciplinas',
                  icon: Icons.library_books,
                  initiallyExpanded: true,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDisciplinasExpanded = expanded;
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDisciplinasInput(),
                              if (disciplinasOferecidos.isNotEmpty)
                                _buildDisciplinasOferecidos()
                            ],
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
                  onPressed: atualizarDisciplinas,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
