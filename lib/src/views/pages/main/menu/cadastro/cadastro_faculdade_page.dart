import 'dart:convert';

import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_endereco_form.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CadastroFaculdadePage extends StatefulWidget {
  final String endpoint;

  const CadastroFaculdadePage({
    super.key,
    required this.endpoint,
  });

  @override
  State<CadastroFaculdadePage> createState() => _CadastroFaculdadePageState();
}

class _CadastroFaculdadePageState extends State<CadastroFaculdadePage> {
  late CadastroController controller;
  final GlobalKey<FormState> faculdadeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> enderecoFormKey = GlobalKey<FormState>();
  String cursosError = '';
  String cadastroError = '';
  bool _isButtonClicked = false;
  bool _isLoading = false;
  final ValueNotifier<bool> _isLoadingController = ValueNotifier(false);
  final TextEditingController courseController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cnpjController = MaskedTextController(mask: '00.000.000/0001-00');
  final TextEditingController telefoneController = MaskedTextController(mask: '(00) 00000-0000');
  final TextEditingController emailResponsavelController = TextEditingController();
  final TextEditingController tipoFaculController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = MaskedTextController(mask: '00000-000');
  final ValueNotifier<bool> isCnpjValid = ValueNotifier<bool>(false);
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
  }

  @override
  void dispose() {
    courseController.dispose();
    nomeController.dispose();
    cnpjController.dispose();
    telefoneController.dispose();
    emailResponsavelController.dispose();
    tipoFaculController.dispose();
    logradouroController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();
    super.dispose();
  }

  Future<http.Response?> cadastrarFaculdade() async {
    final isFaculdadeValid = faculdadeFormKey.currentState?.validate() ?? false;
    final isEnderecoValid = enderecoFormKey.currentState?.validate() ?? false;

    final hasCourses = cursosOferecidos.isNotEmpty;

    setState(() {
      cursosError = (hasCourses ? '' : 'Adicione ao menos um item!');
      cadastroError =
          'OBS: Se teve algum problema verifique se todos os cards estão abertos!';
    });

    if (!isFaculdadeValid || !isEnderecoValid || !hasCourses) {
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    int tipoFaculValue = controller.dropdownValues['TipoFacul'] as int? ?? 0;
    final cleanCNPJ =
        cnpjController.text.replaceAll('.', '').replaceAll('-', '');
    final cleanTelefone = telefoneController.text
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '');
    final cleanCEP = cepController.text.replaceAll('-', '');

    try {
      const url =
          'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/Faculdade';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "nome": nomeController.text,
          "cnpj": cleanCNPJ,
          "telefone": cleanTelefone,
          "emailResponsavel": emailResponsavelController.text,
          "endereco": {
            "logradouro": logradouroController.text,
            "numero": numeroController.text,
            "bairro": bairroController.text,
            "cidade": cidadeController.text,
            "estado": estadoController.text,
            "cep": cleanCEP,
          },
          "tipo": tipoFaculValue,
          "cursosOferecidos": cursosOferecidos,
          "userCPF": await ApiService().recuperarCPF()
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.show(context, 'Faculdade Cadastrada com sucesso!',
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

  bool isDadosEntidadeExpanded = true;
  bool isEnderecoExpanded = false;

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
          title: const Text('Cadastro de Faculdades'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomExpansionCard(
                  formKey: faculdadeFormKey,
                  title: 'Dados da Faculdade',
                  icon: Icons.cases_rounded,
                  initiallyExpanded: isDadosEntidadeExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDadosEntidadeExpanded = expanded;
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
                      'CNPJ',
                      context,
                      cnpjController,
                      !_isLoading,
                      onChanged: (value) {
                        setState(() {
                          controller.updateCNPJNotifier(value);
                        });
                      },
                    ),
                    controller.buildTextInput(
                      'EmailResponsavel',
                      context,
                      emailResponsavelController,
                      !_isLoading,
                      onChanged: (value) {
                        setState(() {
                          controller.updateEmailNotifier(value);
                        });
                      },
                    ),
                    controller.buildTextInput(
                      'Telefone',
                      context,
                      telefoneController,
                      !_isLoading,
                    ),
                    controller.buildDropdown(
                      'TipoFacul',
                      context,
                      !_isLoading,
                      (newValue) {
                        setState(() {
                          controller.dropdownValues['TipoFacul'] = newValue;
                        });
                      },
                    ),
                    _buildCourseInput(),
                    if (cursosOferecidos.isNotEmpty) _buildCursosOferecidos(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 15),
                      child: Text(
                        cursosError,
                        style: TextStyle(color: Colors.red[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
                CustomExpansionCard(
                  formKey: enderecoFormKey,
                  title: 'Endereço',
                  icon: Icons.home,
                  initiallyExpanded: isEnderecoExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isEnderecoExpanded = expanded;
                    });
                  },
                  children: [
                    EnderecoForm(
                      cepController: cepController,
                      logradouroController: logradouroController,
                      numeroController: numeroController,
                      bairroController: bairroController,
                      cidadeController: cidadeController,
                      estadoController: estadoController,
                      isLoadingNotifier: _isLoadingController,
                      isLoading: _isLoading,
                      onSearchPressed: () async {
                        _isLoadingController.value = true;
                        await controller.searchAddress(
                          context: context,
                          cepController: cepController,
                          logradouroController: logradouroController,
                          bairroController: bairroController,
                          cidadeController: cidadeController,
                          estadoController: estadoController,
                          isLoading: _isLoadingController,
                        );
                        _isLoadingController.value = false;
                      },
                    ),
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
                      cadastrarFaculdade();
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
