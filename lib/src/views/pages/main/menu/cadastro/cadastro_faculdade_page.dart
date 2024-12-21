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
  bool _isLoading = false;
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailResponsavelController =
      TextEditingController();
  final TextEditingController tipoFaculController = TextEditingController();
  final TextEditingController adicionarController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
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
    _courseController.dispose();
    nomeController.dispose();
    cnpjController.dispose();
    telefoneController.dispose();
    emailResponsavelController.dispose();
    tipoFaculController.dispose();
    adicionarController.dispose();
    logradouroController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();
    super.dispose();
  }

  Future<http.Response?> cadastrarFaculdade() async {
    setState(() {
      _isLoading = true;
    });

    int tipoFaculValue = controller.dropdownValues['TipoFacul'] as int? ?? 0;

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
          "cnpj": cnpjController.text,
          "telefone": telefoneController.text,
          "emailResponsavel": emailResponsavelController.text,
          "endereco": {
            "logradouro": logradouroController.text,
            "numero": numeroController.text,
            "bairro": bairroController.text,
            "cidade": cidadeController.text,
            "estado": estadoController.text,
            "cep": cepController.text
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
      controller: _courseController,
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

  String? validateCnpj(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo CNPJ é obrigatório';
    } else if (!validateCnpjLogic(value)) {
      return 'CNPJ inválido';
    }
    return null;
  }

  void updateCnpjNotifier() {
    final text = cnpjController.text;
    isCnpjValid.value = text.isNotEmpty && validateCnpjLogic(text);
  }

  bool validateCnpjLogic(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');

    if (value.length != 14 || RegExp(r'^(\d)\1*$').hasMatch(value)) {
      return false;
    }

    return _isValidCnpj(value);
  }

  bool _isValidCnpj(String cnpj) {
    int calculateDigit(List<int> digits, List<int> weights) {
      int sum = 0;
      for (int i = 0; i < digits.length; i++) {
        sum += digits[i] * weights[i];
      }
      int remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final digits = cnpj.split('').map(int.parse).toList();

    final firstCheckDigit = calculateDigit(
        digits.sublist(0, 12), [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    if (firstCheckDigit != digits[12]) {
      return false;
    }

    final secondCheckDigit = calculateDigit(
        digits.sublist(0, 13), [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    return secondCheckDigit == digits[13];
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
    
    return Scaffold(
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
                  ),
                  controller.buildTextInput(
                    'Telefone',
                    context,
                    telefoneController,
                    !_isLoading,
                  ),
                  controller.buildTextInput(
                    'EmailResponsavel',
                    context,
                    emailResponsavelController,
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
                    cadastrarFaculdade();
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
