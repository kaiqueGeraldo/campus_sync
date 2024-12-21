import 'dart:convert';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/selecionar_faculdade_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = false;
  final TextEditingController nomeUniversidadeController =
      TextEditingController();
  final TextEditingController cnpjUniversidadeController =
      TextEditingController();
  final TextEditingController contatoUniversidadeController =
      TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _disciplinasController = TextEditingController();
  bool atualizarTurmas = false;
  bool atualizarDisciplinas = false;
  Map<String, dynamic>? faculdadeSelecionada;
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
  List<DropdownMenuItem<int>> turmasDropdownItems = [];
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
  List<String> cursosDisponiveisPorFculdade = [];
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

  bool isDadosUniversidadeExpanded = true;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    _loadUserData();
  }

  @override
  void dispose() {
    nomeUniversidadeController.dispose();
    cnpjUniversidadeController.dispose();
    contatoUniversidadeController.dispose();
    for (var controller in turmasNomeControllers) {
      controller.dispose();
    }
    for (var controller in turmasPeriodoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService().fetchUserProfile(context);
    try {
      if (userData['universidadeNome'] != null &&
              userData['universidadeNome'].isNotEmpty ||
          userData['universidadeCNPJ'] != null &&
              userData['universidadeCNPJ'].isNotEmpty ||
          userData['universidadeContatoInfo'] != null &&
              userData['universidadeContatoInfo'].isNotEmpty) {
        setState(() {
          nomeUniversidadeController.text = userData['universidadeNome'] ?? '';
          cnpjUniversidadeController.text = userData['universidadeCNPJ'] ?? '';
          contatoUniversidadeController.text =
              userData['universidadeContatoInfo'] ?? '';
          _isDataLoaded = true;
        });
      } else {
        setState(() {
          nomeUniversidadeController.text = '';
          cnpjUniversidadeController.text = '';
          contatoUniversidadeController.text = '';
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _updateDados() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String? cpf = prefs.getString('userCpf');
    String? email = prefs.getString('userEmail');
    String? nome = prefs.getString('userNome');

    await prefs.setString(
        'userUniversidadeNome', nomeUniversidadeController.text);
    await prefs.setString(
        'userUniversidadeCNPJ', cnpjUniversidadeController.text);
    await prefs.setString(
        'userUniversidadeContato', contatoUniversidadeController.text);

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
            'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/User/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cpf': cpf,
          'nome': nome,
          'email': email,
          'universidadeNome': nomeUniversidadeController.text,
          'universidadeCNPJ': cnpjUniversidadeController.text,
          'universidadeContatoInfo': contatoUniversidadeController.text,
        }),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        CustomSnackbar.show(context, 'Universidade atualizada com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(
          context,
          'Erro ao atualizar universidade: ${response.body}',
          backgroundColor: AppColors.errorColor,
        );
      }
    } catch (e) {
      print('Erro ao atualizar universidade: $e');
      CustomSnackbar.show(context, 'Erro ao atualizar universidade: $e',
          backgroundColor: AppColors.errorColor);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    switch (field) {
      case 'UniversidadeNome':
        fieldController = nomeUniversidadeController;
        break;
      case 'UniversidadeCNPJ':
        fieldController = cnpjUniversidadeController;
        break;
      case 'UniversidadeContatoInfo':
        fieldController = contatoUniversidadeController;
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

  Widget _buildDropdown(String field) {
    List<DropdownMenuItem<int>> items = controller.getDropdownItems(field);

    if (field == 'Curso') {
      items = cursosDropdownItems;
    }

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

          if (field == 'Curso' && newValue != null) {
            setState(() {
              controller.dropdownValues['Turma'] = null;
            });
          }
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

  Widget _buildCourseInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _courseController,
            onChanged: _filterCursos,
            decoration: InputDecoration(
              labelText: 'Adicionar Curso',
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
          if (_courseController.text.isNotEmpty && filteredCursos.isNotEmpty)
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
                  itemCount: filteredCursos.length,
                  itemBuilder: (context, index) {
                    final curso = filteredCursos[index];
                    return ListTile(
                      title: Text(curso),
                      onTap: () => _addCurso(curso),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCursosOferecidos() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cursos Oferecidos:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cursosOferecidos.map((curso) {
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
                  onDeleted: () => _removeCurso(curso),
                ),
              );
            }).toList(),
          ),
          if (cursosOferecidos.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _removeAllCurso,
                child: const Text('Remover tudo',
                    style: TextStyle(color: AppColors.buttonColor)),
              ),
            )
        ],
      ),
    );
  }

  void _addCurso(String curso) {
    setState(() {
      if (!cursosOferecidos.contains(curso)) {
        cursosOferecidos.add(curso);
      }
      _courseController.clear();
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
          controller.dropdownValues['Curso'] = null;
        });

        final cursos = await ApiService().buscarCursosPorFaculdade(
          faculdadeSelecionada!['id'],
        );

        print(cursos);

        setState(() {
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
          content: Text(
              'Erro ao carregar faculdades. Verifique se existe alguma faculdade cadastrada e tente novamente.'),
        ),
      );
    }
  }

  Widget _buildFaculdadeInput() {
    return Column(
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
                  final disciplina = filteredDisciplinas[index];
                  return ListTile(
                    title: Text(disciplina),
                    onTap: () => _addDisciplina(disciplina),
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
            'Disciplinas Oferecidas:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: disciplinasOferecidos.map((disciplina) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 110,
                ),
                child: Chip(
                  label: GestureDetector(
                    onTap: () {
                      CustomSnackbar.show(
                        context,
                        disciplina,
                        backgroundColor: AppColors.socialButtonColor,
                      );
                    },
                    child: Text(
                      disciplina,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  backgroundColor: AppColors.lightGreyColor,
                  deleteIcon: const Icon(Icons.close, color: Colors.red),
                  onDeleted: () => _removeDisciplina(disciplina),
                ),
              );
            }).toList(),
          ),
          if (disciplinasOferecidos.length > 1)
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

  Widget _buildCheckbox() {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: const EdgeInsets.only(left: 0),
          value: atualizarDisciplinas,
          onChanged: (value) {
            setState(() {
              atualizarDisciplinas = value ?? false;
              if (atualizarDisciplinas) {
                controller.controllers['NomeMae']?.clear();
                controller.controllers['TelefoneMae']?.clear();
              }
            });
          },
          title: const Text('Deseja Atualizar as disciplinas?'),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.buttonColor,
        ),
        CheckboxListTile(
          contentPadding: const EdgeInsets.only(left: 0),
          value: atualizarTurmas,
          onChanged: (value) {
            setState(() {
              atualizarTurmas = value ?? false;
              if (atualizarTurmas) {
                controller.controllers['NomeMae']?.clear();
                controller.controllers['TelefoneMae']?.clear();
              }
            });
          },
          title: const Text('Deseja Atualizar as turmas?'),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.buttonColor,
        ),
      ],
    );
  }

  bool isDadosEntidadeExpanded = true;

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
        title: Text('Configurar ${widget.endpoint}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: _isDataLoaded
              ? Column(
                  children: [
                    _buildCard(
                      title: _getCardTitle(),
                      icon: _getCardIcon(),
                      initiallyExpanded: isDadosEntidadeExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          isDadosEntidadeExpanded = expanded;
                        });
                      },
                      children: _buildFormFields(),
                    ),
                    CustomButton(
                      text: _isLoading ? '' : 'Atualizar Dados',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (!_isLoading) {
                          _updateDados();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : _buildLoadingState(),
        ),
      ),
    );
  }

// Função que define o título do card com base no endpoint
  String _getCardTitle() {
    if (widget.endpoint == 'Universidade') {
      return 'Dados da Universidade';
    } else if (widget.endpoint == 'Faculdade') {
      return 'Dados da Faculdade';
    } else {
      return 'Dados de Cursos';
    }
  }

// Função que define o ícone do card com base no endpoint
  IconData _getCardIcon() {
    if (widget.endpoint == 'Universidade') {
      return Icons.account_balance;
    } else if (widget.endpoint == 'Faculdade') {
      return Icons.cast_for_education_rounded;
    } else {
      return Icons.my_library_books_outlined;
    }
  }

// Função que retorna os campos do formulário com base no endpoint
  List<Widget> _buildFormFields() {
    if (widget.endpoint == 'Universidade') {
      return [
        _buildTextInput('UniversidadeNome'),
        _buildTextInput('UniversidadeCNPJ'),
        _buildTextInput('UniversidadeContatoInfo')
      ];
    } else if (widget.endpoint == 'Faculdade') {
      return [
        _buildFaculdadeInput(),
        if (faculdadeSelecionada != null) _buildCourseInput(),
        if (cursosOferecidos.isNotEmpty) _buildCursosOferecidos(),
      ];
    } else if (widget.endpoint == 'Curso') {
      return [
        _buildFaculdadeInput(),
        if (faculdadeSelecionada != null) _buildCheckbox(),
        if (faculdadeSelecionada != null && atualizarDisciplinas)
          const Text('Disciplinas',
              style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (faculdadeSelecionada != null && atualizarDisciplinas)
          _buildDropdown('Curso'),
        if (faculdadeSelecionada != null &&
            atualizarDisciplinas &&
            cursosDropdownItems.isNotEmpty)
          _buildDisciplinasInput(),
        if (disciplinasOferecidos.isNotEmpty) _buildDisciplinasOferecidos(),
        const SizedBox(height: 15),
        if (faculdadeSelecionada != null && atualizarTurmas)
          const Text('Turmas', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (faculdadeSelecionada != null && atualizarTurmas)
          _buildDropdown('Turmas'),
        _buildTurmasInputs(),
      ];
    }
    return [];
  }

// Função para exibir o estado de carregamento
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: LinearProgressIndicator(
        backgroundColor: AppColors.lightGreyColor,
        color: AppColors.buttonColor,
        valueColor: AlwaysStoppedAnimation(AppColors.buttonColor),
        minHeight: 8,
      ),
    );
  }
}
