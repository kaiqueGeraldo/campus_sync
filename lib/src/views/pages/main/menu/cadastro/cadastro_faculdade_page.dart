import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';

class CadastroFaculdadePage extends StatefulWidget {
  final String endpoint;
  final Map<String, dynamic> initialData;

  const CadastroFaculdadePage({
    super.key,
    required this.endpoint,
    required this.initialData,
  });

  @override
  State<CadastroFaculdadePage> createState() => _CadastroFaculdadePageState();
}

class _CadastroFaculdadePageState extends State<CadastroFaculdadePage> {
  late CadastroController controller;
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
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
    controller.initControllers(widget.initialData);
    print('Initial Data: ${widget.initialData}');
  }

  Widget _buildTextInput(String field) {
    String labelText = controller.fieldNames[field] ?? field;
    TextInputType keyboardType = controller.getKeyboardType(field);
    int? maxLength = controller.getMaxLength(field);

    String? Function(String?)? validator;
    if (field == 'CNPJ') {
      validator = validateCnpj;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomInputTextCadastro(
        controller: controller.controllers[field] as TextEditingController,
        labelText: labelText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        suffixIcon: field == 'CNPJ'
            ? ValueListenableBuilder<bool>(
                valueListenable: isCnpjValid,
                builder: (context, isValid, _) {
                  return controller.controllers[field]!.text.isEmpty
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
    final text = controller.controllers['CNPJ']!.text;
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
    final hasEnderecoFields = controller.controllers.keys
        .any((field) => controller.isEnderecoField(field));
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
              Card(
                color: AppColors.lightGreyColor,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  backgroundColor: AppColors.lightGreyColor,
                  iconColor: isDadosEntidadeExpanded
                      ? AppColors.buttonColor
                      : Colors.black,
                  leading: Icon(
                    Icons.cases_rounded,
                    color: isDadosEntidadeExpanded
                        ? AppColors.buttonColor
                        : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  initiallyExpanded: isDadosEntidadeExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDadosEntidadeExpanded = expanded;
                    });
                  },
                  title: Text(
                    'Dados ${widget.endpoint}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDadosEntidadeExpanded
                          ? AppColors.buttonColor
                          : Colors.black,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...controller.controllers.keys
                                .where((field) =>
                                    !controller.isEnderecoField(field))
                                .map((field) => _buildTextInput(field)),
                            ...controller.dropdownValues.keys
                                .where((field) =>
                                    !controller.isEnderecoField(field))
                                .map((field) => _buildDropdown(field)),
                            _buildCourseInput(),
                            if (cursosOferecidos.isNotEmpty)
                              _buildCursosOferecidos(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasEnderecoFields)
                Card(
                  color: AppColors.lightGreyColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    iconColor: isEnderecoExpanded
                        ? AppColors.buttonColor
                        : Colors.black,
                    leading: Icon(
                      Icons.home_rounded,
                      color: isEnderecoExpanded
                          ? AppColors.buttonColor
                          : Colors.black,
                    ),
                    backgroundColor: AppColors.lightGreyColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    initiallyExpanded: isEnderecoExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        isEnderecoExpanded = expanded;
                      });
                    },
                    title: Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEnderecoExpanded
                            ? AppColors.buttonColor
                            : Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...controller.controllers.keys
                                  .where((field) =>
                                      controller.isEnderecoField(field))
                                  .map((field) => _buildTextInput(field)),
                              ...controller.dropdownValues.keys
                                  .where((field) =>
                                      controller.isEnderecoField(field))
                                  .map((field) => _buildDropdown(field)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    controller.cadastrar(context, widget.endpoint);
                  },
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
