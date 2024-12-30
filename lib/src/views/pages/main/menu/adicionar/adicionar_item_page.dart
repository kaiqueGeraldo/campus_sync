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
import 'package:campus_sync/src/views/pages/main/menu/adicionar/adicionar_disciplinas_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/adicionar/adicionar_turmas_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdicionarItemPage extends StatefulWidget {
  final String endpoint;

  const AdicionarItemPage({
    super.key,
    required this.endpoint,
  });

  @override
  State<AdicionarItemPage> createState() => _AdicionarItemPageState();
}

class _AdicionarItemPageState extends State<AdicionarItemPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CadastroController controller;
  final GlobalKey<FormState> dadosFormKey = GlobalKey<FormState>();
  String cursosError = '';
  bool _isLoading = false;
  bool isCursosExpanded = true;

  final TextEditingController courseController = TextEditingController();
  final List<String> cursosOferecidos = [];
  List<String> filteredCursos = [];
  List<String> cursosDisponiveis = [
    'Engenharia Civil',
    'Engenharia Elétrica',
    'Engenharia Mecânica',
    'Engenharia de Produção',
    'Engenharia Química',
    'Engenharia de Computação',
    'Engenharia Ambiental',
    'Engenharia de Petróleo',
    'Engenharia Aeroespacial',
    'Engenharia Biomédica',
    'Engenharia de Software',
    'Engenharia Agronômica',
    'Engenharia de Materiais',
    'Engenharia Nuclear',
    'Matemática',
    'Física',
    'Química',
    'Estatística',
    'Ciência da Computação',
    'Sistemas de Informação',
    'Análise e Desenvolvimento de Sistemas',
    'Tecnologia em Redes de Computadores',
    'Tecnologia em Banco de Dados',
    'Tecnologia em Automação Industrial',
    'Tecnologia em Mecatrônica',
    'Tecnologia em Gestão da Tecnologia da Informação',
    'Tecnologia em Inteligência Artificial',
    'Arquitetura e Urbanismo',
    'Medicina',
    'Enfermagem',
    'Odontologia',
    'Fisioterapia',
    'Farmácia',
    'Biomedicina',
    'Nutrição',
    'Medicina Veterinária',
    'Educação Física',
    'Psicologia',
    'Terapia Ocupacional',
    'Gerontologia',
    'Saúde Pública',
    'Fonoaudiologia',
    'Ciências Biológicas',
    'Biotecnologia',
    'Ciências do Esporte',
    'Direito',
    'Sociologia',
    'Filosofia',
    'Antropologia',
    'História',
    'Geografia',
    'Pedagogia',
    'Letras (Português/Inglês/Espanhol/Francês etc.)',
    'Serviço Social',
    'Ciência Política',
    'Relações Internacionais',
    'Estudos de Gênero',
    'Arqueologia',
    'Comunicação Social (Jornalismo)',
    'Publicidade e Propaganda',
    'Rádio, TV e Internet',
    'Produção Cultural',
    'Design Gráfico',
    'Design de Moda',
    'Design de Interiores',
    'Design de Produto',
    'Artes Visuais',
    'Artes Cênicas (Teatro)',
    'Música',
    'Cinema e Audiovisual',
    'Administração',
    'Contabilidade',
    'Economia',
    'Gestão de Recursos Humanos',
    'Gestão Financeira',
    'Gestão Comercial',
    'Comércio Exterior',
    'Logística',
    'Marketing',
    'Empreendedorismo',
    'Negócios Internacionais',
    'Gestão Pública',
    'Controladoria e Auditoria',
    'Gestão de Projetos',
    'Gestão da Qualidade',
    'Agronomia',
    'Engenharia Florestal',
    'Zootecnia',
    'Ciências Ambientais',
    'Engenharia de Pesca',
    'Gestão Ambiental',
    'Tecnologia em Agroecologia',
    'Tecnologia em Gestão de Agronegócios',
    'Tecnologia em Irrigação e Drenagem',
    'Ciências do Solo',
    'Turismo',
    'Hotelaria',
    'Gastronomia',
    'Eventos e Cerimonial',
    'Lazer e Recreação',
    'Gestão de Turismo Sustentável',
    'Formação de Professores (Licenciatura em diversas áreas)',
    'Educação Especial',
    'Tecnologias Educacionais',
    'Educação Infantil',
    'Pedagogia Empresarial',
    'Ciência de Dados',
    'Inteligência Artificial',
    'Robótica',
    'Big Data e Analytics',
    'Cibersegurança',
    'Blockchain e Criptomoedas',
    'Realidade Virtual e Aumentada',
    'Engenharia Física',
    'Química Industrial',
    'Bioinformática',
    'Ecologia',
    'Ciências Forenses',
    'Oceanografia',
    'Paleontologia',
    'Estudos Ambientais',
    'Desenvolvimento Sustentável',
    'Economia Circular',
    'Gestão Esportiva',
    'Gestão de Clubes e Federações',
    'Produção de Conteúdo Digital',
    'Produção Musical',
    'Produção de Games',
    'Design de Jogos Digitais',
    'Tecnologia em Design Gráfico',
    'Tecnologia em Fotografia',
    'Tecnologia em Produção Audiovisual',
    'Tecnologia em Comércio Eletrônico',
    'Tecnologia em Gestão de Saúde',
    'Tecnologia em Gestão de Segurança Privada',
    'Tecnologia em Gestão de Logística',
    'Tecnologia em Energias Renováveis',
    'Enologia',
    'Ciências Atuariais',
    'Biblioteconomia',
    'Arquivologia',
    'Museologia',
    'Teologia',
    'Línguas Estrangeiras Aplicadas',
    'Terapias Naturais',
    'Gestão de Conflitos',
    'Estudos Religiosos',
    'Design Estratégico',
    'Produção Editorial',
    'Perícia Criminal',
  ];

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<http.Response?> atualizarCursos() async {
    final isDadosValid = dadosFormKey.currentState?.validate() ?? false;

    final hasCourses = cursosOferecidos.isNotEmpty;

    setState(() {
      cursosError = (hasCourses ? null : 'Adicione ao menos um item!')!;
    });

    if (!isDadosValid || !hasCourses) {
      return null;
    }
    final cursosParaAdicionar = cursosOferecidos.toList();

    final faculdadeSelecionada = controller.faculdadeSelecionadaNotifier.value;
    if (faculdadeSelecionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, selecione uma faculdade antes de continuar.'),
        ),
      );
      return null;
    }

    final faculdadeId = faculdadeSelecionada['id'];
    print('ID FACULDADE: $faculdadeId');
    if (faculdadeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faculdade inválida. Tente novamente.'),
        ),
      );
      return null;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final cursosExistentes =
          await ApiService().buscarCursosPorFaculdade(faculdadeId);

      List<String> cursosDuplicados = [];
      List<String> cursosAAdicionar = [];

      final nomesCursosExistentes =
          cursosExistentes.map((curso) => curso['nome'] as String).toList();

      for (var curso in cursosParaAdicionar) {
        if (nomesCursosExistentes.contains(curso)) {
          cursosDuplicados.add(curso);
        } else {
          cursosAAdicionar.add(curso);
        }
      }

      if (cursosDuplicados.isNotEmpty) {
        final duplicadasMensagem = cursosDuplicados.join(', ');
        customShowDialog(
          context: context,
          title: 'Cursos Duplicados',
          content:
              'Os seguintes cursos já estavam cadastrados na faculdade: $duplicadasMensagem.\nOs demais foram adicionados com sucesso.',
          confirmText: 'OK',
          onConfirm: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }

      if (cursosAAdicionar.isNotEmpty) {
        final response = await http.put(
          Uri.parse(
              '${ApiService.baseUrl}/Faculdade/adicionar-cursos/$faculdadeId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'cursosOferecidos': cursosAAdicionar}),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (cursosDuplicados.isNotEmpty) {
          } else {
            CustomSnackbar.show(context, 'Cursos atualizados com sucesso!',
                backgroundColor: AppColors.successColor);
            Navigator.pop(context);
          }
          return response;
        } else {
          print('Erro ao adicionar cursos: ${response.statusCode}');
          print('Detalhes: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao adicionar cursos. Código: ${response.statusCode}. Verifique os dados.'),
            ),
          );
          return null;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não há novos cursos para adicionar.'),
          ),
        );
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
    return null;
  }

  Widget _buildCourseInput() {
    return controller.buildListInput(
      context,
      label: 'Adicionar Curso',
      enabled: !_isLoading,
      controller: courseController,
      itemsDisponiveis: cursosDisponiveis,
      filteredItems: filteredCursos,
      onAddItem: _addCurso,
      onRemoveItem: _removeCurso,
      onRemoveAll: _removeAllCurso,
      onFilter: _filterCursos,
    );
  }

  Widget _buildCursosOferecidos() {
    return controller.buildSelectedItems(
      context,
      label: 'Cursos Oferecidos:',
      itemsSelecionados: cursosOferecidos,
      onRemoveItem: (curso) => _removeCurso(curso),
      onRemoveAll: _removeAllCurso,
    );
  }

  void _addCurso(String curso) {
    setState(() {
      if (!cursosOferecidos.contains(curso)) {
        cursosOferecidos.add(curso);
      }
      courseController.clear();
      filteredCursos.clear();
    });
  }

  void _removeCurso(String curso) {
    setState(() {
      cursosOferecidos.remove(curso);
    });
  }

  void _removeAllCurso() {
    customShowDialog(
        context: context,
        title: 'Confirmar Exclusão',
        content: 'Tem certeza que deseja remover todos os itens da lista?',
        cancelText: 'Não',
        onCancel: () => Navigator.pop(context),
        confirmText: 'Sim',
        onConfirm: () {
          setState(() {
            cursosOferecidos.clear();
          });
          Navigator.pop(context);
        });
  }

  void _filterCursos(String query) {
    setState(() {
      filteredCursos = cursosDisponiveis
          .where((curso) => curso.toLowerCase().contains(query.toLowerCase()))
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
            title: Text(widget.endpoint == 'Curso'
                ? 'Adicionar Turmas e/ou Disciplinas'
                : 'Adicionar Cursos'),
            bottom: widget.endpoint == 'Curso'
                ? TabBar(
                    dividerColor: AppColors.textColor,
                    indicatorColor: AppColors.textColor,
                    labelColor: AppColors.textColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: AppColors.unselectedColor,
                    splashBorderRadius: BorderRadius.circular(5),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return states.contains(WidgetState.focused)
                            ? null
                            : AppColors.socialButtonColor;
                      },
                    ),
                    controller: _tabController,
                    tabs: const <Widget>[
                      Tab(icon: Icon(Icons.people_rounded)),
                      Tab(icon: Icon(Icons.library_books)),
                    ],
                  )
                : null,
          ),
          body: widget.endpoint == 'Curso'
              ? TabBarView(
                  controller: _tabController,
                  children: const [
                    AdicionarTurmasPage(),
                    AdicionarDisciplinasPage(),
                  ],
                )
              : cursoDropdown()),
    );
  }

  Widget cursoDropdown() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            CustomExpansionCard(
              formKey: dadosFormKey,
              title: 'Adicionar Cursos',
              icon: Icons.school,
              initiallyExpanded: true,
              onExpansionChanged: (expanded) {
                setState(() {
                  isCursosExpanded = expanded;
                });
              },
              children: [
                controller.buildFaculdadeInput(context),
                ValueListenableBuilder<Map>(
                  valueListenable: controller.faculdadeSelecionadaNotifier,
                  builder: (context, faculdadeSelecionada, child) {
                    if (faculdadeSelecionada.isNotEmpty) {
                      print('FACULDADE: $faculdadeSelecionada');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCourseInput(),
                            if (cursosOferecidos.isNotEmpty)
                              _buildCursosOferecidos(),
                          ],
                        ),
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
              onPressed: atualizarCursos,
            ),
          ],
        ),
      ),
    );
  }
}
