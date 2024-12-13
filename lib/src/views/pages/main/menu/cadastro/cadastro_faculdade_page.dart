import 'dart:convert';

import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        print('Erro ao cadastrar faculdade: ${response.statusCode}');
        print('Detalhes: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      return null;
    }
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
    fieldController = controller.getMaskedController(field, "");

    switch (field) {
      case 'Curso':
        fieldController = _courseController;
        break;
      case 'Nome':
        fieldController = nomeController;
        break;
      case 'CNPJ':
        fieldController = cnpjController;
        break;
      case 'Telefone':
        fieldController = telefoneController;
        break;
      case 'EmailResponsavel':
        fieldController = emailResponsavelController;
        break;
      case 'TipoFacul':
        fieldController = tipoFaculController;
        break;
      case 'Adicionar':
        fieldController = adicionarController;
        break;
      case 'EnderecoLogradouro':
        fieldController = logradouroController;
        break;
      case 'EnderecoNumero':
        fieldController = numeroController;
        break;
      case 'EnderecoBairro':
        fieldController = bairroController;
        break;
      case 'EnderecoCidade':
        fieldController = cidadeController;
        break;
      case 'EnderecoEstado':
        fieldController = estadoController;
        break;
      case 'EnderecoCEP':
        fieldController = cepController;
        break;
      default:
        fieldController = TextEditingController();
    }

    String? Function(String?)? validator;
    if (field == 'CNPJ') {
      validator = validateCnpj;
    }

    return Padding(
      padding: customPadding ?? const EdgeInsets.only(bottom: 16),
      child: CustomInputTextCadastro(
        controller: fieldController,
        labelText: labelText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enabled: enabled && !disabled,
        validator: validator,
        suffixIcon: field == 'CNPJ'
            ? ValueListenableBuilder<bool>(
                valueListenable: isCnpjValid,
                builder: (context, isValid, _) {
                  return cnpjController.text.isEmpty
                      ? const Icon(
                          Icons.info,
                          color: Colors.grey,
                        )
                      : Icon(
                          isCnpjValid.value ? Icons.check_circle : Icons.error,
                          color: isCnpjValid.value ? Colors.green : Colors.red,
                        );
                },
              )
            : null,
        onChanged: (value) {
          setState(() {
            updateCnpjNotifier();
          });
        },
      ),
    );
  }

  Widget _buildDropdown(String field) {
    List<DropdownMenuItem<int>> items = controller.getDropdownItems(field);

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

  Widget _buildCourseInput() {
    return Column(
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
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Cadastro de ${widget.endpoint}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                title: 'Dados de ${widget.endpoint}',
                icon: Icons.cases_rounded,
                initiallyExpanded: isDadosEntidadeExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isDadosEntidadeExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('Nome'),
                  _buildTextInput('CNPJ'),
                  _buildTextInput('Telefone'),
                  _buildTextInput('EmailResponsavel'),
                  _buildDropdown('TipoFacul'),
                  _buildCourseInput(),
                  if (cursosOferecidos.isNotEmpty) _buildCursosOferecidos(),
                ],
              ),
              _buildCard(
                title: 'Endereço',
                icon: Icons.home,
                initiallyExpanded: isEnderecoExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isEnderecoExpanded = expanded;
                  });
                },
                children: [
                  _buildTextInput('EnderecoLogradouro'),
                  _buildTextInput('EnderecoNumero'),
                  _buildTextInput('EnderecoBairro'),
                  _buildTextInput('EnderecoCidade'),
                  _buildTextInput('EnderecoEstado'),
                  _buildTextInput('EnderecoCEP'),
                ],
              ),
              CustomButton(
                text: 'Cadastrar',
                onPressed: () {
                  cadastrarFaculdade();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
