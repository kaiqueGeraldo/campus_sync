import 'dart:math';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/enums/periodo_curso.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/services/validators/date_input_formater.dart';
import 'package:campus_sync/src/services/validators/input_validators.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/menu/cadastro/selecionar_faculdade_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class CadastroController {
  final bool isLoading = false;
  final List<String> cursosSelecionados = [];
  final List<int> cursosOferecidos = [];
  final List<String> disciplinasSelecionados = [];
  final List<int> disciplinasOferecidos = [];
  List<DropdownMenuItem<int>> cursosDropdownItems = [];
  Map<int, List<dynamic>> turmasPorCurso = {};
  final Map<String, TextEditingController> controllers = {};
  Map<String, dynamic> dropdownValues = {};
  Map<String, dynamic> selectedValues = {};
  final Map<String, String> fieldNames = {
    'CapacidadeMaxima': 'Capacidade Máxima',
    'CPF': 'CPF',
    'CNPJ': 'CNPJ',
    'Cor/Raca/Etnia': 'Cor/Raça/Etnia',
    'CursoId': 'Curso',
    'DataAdmissao': 'Data de Admissão',
    'DataMatricula': 'Data da Matrícula',
    'DataNascimento': 'Data de Nascimento',
    'Descricao': 'Descrição',
    'Email': 'E-mail',
    'EmailResponsavel': 'E-mail do responsável',
    'EnderecoCEP': 'CEP',
    'EnderecoCidade': 'Cidade',
    'EnderecoEstado': 'Estado',
    'EnderecoLogradouro': 'Logradouro',
    'EnderecoNumero': 'Número',
    'EnderecoBairro': 'Bairro',
    'EstadoCivil': 'Estado Cívil',
    'EstudanteId': 'Estudante',
    'FaculdadeId': 'Faculdade',
    'Formacoes': 'Formações',
    'Nome': 'Nome',
    'NomeMae': 'Nome da Mãe',
    'NomePai': 'Nome do Pai',
    'NumeroMatricula': 'N° de Matrícula',
    'NumeroRegistro': 'N° de Registro',
    'PeriodoCurso': 'Período do Curso',
    'PeriodoTurma': 'Turma',
    'TelefoneMae': 'Telefone Mãe',
    'TelefonePai': 'Telefone Pai',
    'TipoFacul': 'Tipo de Faculdade',
    'TituloEleitor': 'Título de Eleitor',
    'TurmaId': 'Turma',
    'UniversidadeNome': 'Nome',
    'UniversidadeCNPJ': 'CNPJ',
    'UniversidadeContatoInfo': 'Telefone de Contato',
  };
  ValueNotifier<Map<String, dynamic>> faculdadeSelecionadaNotifier =
      ValueNotifier<Map<String, dynamic>>({});
  ValueNotifier<List<DropdownMenuItem<int>>> turmasDropdownItemsNotifier =
      ValueNotifier([]);
  ValueNotifier<List<DropdownMenuItem<int>>> cursosDropdownItemsNotifier =
      ValueNotifier<List<DropdownMenuItem<int>>>([]);
  ValueNotifier<int?> cursoSelecionadoNotifier = ValueNotifier<int?>(null);
  final isCpfValid = ValueNotifier<bool>(true);
  final isEmailValid = ValueNotifier<bool>(true);
  final isCNPJValid = ValueNotifier<bool>(true);

  // Atualizar CPF dinamicamente
  void updateCpfNotifier(String text) {
    isCpfValid.value = InputValidators.validateCpfLogic(text);
  }

  // Atualizar Email dinamicamente
  void updateEmailNotifier(String text) {
    isEmailValid.value = InputValidators.validateEmailLogic(text);
  }

  void updateCNPJNotifier(String text) {
    isCNPJValid.value = InputValidators.validateCnpjLogic(text);
  }

  void atualizarFaculdadeSelecionada(Map<String, dynamic> faculdade) {
    faculdadeSelecionadaNotifier.value = faculdade;
  }

  void atualizarCursosDropdown(List<DropdownMenuItem<int>> cursos) {
    cursosDropdownItemsNotifier.value = cursos;
  }

  void initControllers(Map<String, dynamic> initialData) {
    initialData.forEach((key, value) {
      if (isDropdownField(key)) {
        dropdownValues[key] = value is int ? value : null;
      } else if (key == 'CursosOferecidos' || key == 'DisciplinasOferecidos') {
        cursosOferecidos.clear();
        if (value is List) {
          cursosOferecidos.addAll(value.map<int>((e) => e as int));
          disciplinasOferecidos.addAll(value.map<int>((e) => e as int));
        }
      } else {
        controllers[key] = getMaskedController(key, value?.toString() ?? '');
      }
    });
  }

  void resetControllers() {
    controllers.forEach((key, controller) => controller.clear());
    dropdownValues.clear();
  }

  TextEditingController getMaskedController(String field, String initialValue) {
    switch (field) {
      case 'CPF':
        return MaskedTextController(mask: '000.000.000-00', text: initialValue);
      case 'CNPJ':
        return MaskedTextController(
            mask: '00.000.000/0001-00', text: initialValue);
      case 'RG':
        return MaskedTextController(mask: '00.000.000-0', text: initialValue);
      case 'Celular':
      case 'Telefone':
        return MaskedTextController(
            mask: '(00) 00000-0000', text: initialValue);
      case 'EnderecoCEP':
        return MaskedTextController(mask: '00000-000', text: initialValue);
      case 'DataMatricula':
      case 'DataNascimento':
      case 'DataAdmissao':
        return MaskedTextController(mask: '00/00/0000', text: initialValue);
      default:
        return TextEditingController(text: initialValue);
    }
  }

  int? getMaxLength(String field) {
    switch (field) {
      case 'Mensalidade':
        return 12;
      case 'EnderecoEstado':
        return 2;
      default:
        return 50;
    }
  }

  TextInputType getKeyboardType(String field) {
    switch (field) {
      case 'CPF':
      case 'CNPJ':
      case 'RG':
      case 'Mensalidade':
      case 'Celular':
      case 'EnderecoNumero':
      case 'Telefone':
      case 'EnderecoCEP':
      case 'TituloEleitor':
        return TextInputType.number;
      case 'Email':
      case 'EmailResponsavel':
        return TextInputType.emailAddress;
      case 'DataNascimento':
      case 'DataMatricula':
      case 'DataAdmissao':
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }

  bool isDropdownField(String field) {
    return field == 'TipoFacul' ||
        field == 'PeriodoCurso' ||
        field == 'Turmas' ||
        field == 'Curso' ||
        field == 'Cargo' ||
        field == 'EstadoCivil' ||
        field == 'Nacionalidade' ||
        field == 'Escolaridade' ||
        field == 'Cor/Raca/Etnia';
  }

  // #region GetDropdownItens
  List<DropdownMenuItem<int>> getDropdownItems(String field,
      {int? faculdadeId}) {
    switch (field) {
      case 'TipoFacul':
        return const [
          DropdownMenuItem(value: 0, child: Text('Pública')),
          DropdownMenuItem(value: 1, child: Text('Privada')),
          DropdownMenuItem(value: 2, child: Text('Militar')),
        ];
      case 'PeriodoCurso':
        return const [
          DropdownMenuItem(value: 0, child: Text('Matutino')),
          DropdownMenuItem(value: 1, child: Text('Vespertino')),
          DropdownMenuItem(value: 2, child: Text('Noturno')),
          DropdownMenuItem(value: 3, child: Text('Integral')),
        ];
      case 'Turmas':
        return const [
          DropdownMenuItem(value: 1, child: Text('1')),
          DropdownMenuItem(value: 2, child: Text('2')),
          DropdownMenuItem(value: 3, child: Text('3')),
          DropdownMenuItem(value: 4, child: Text('4')),
        ];
      case 'EstadoCivil':
        return const [
          DropdownMenuItem(value: 0, child: Text('Solteiro')),
          DropdownMenuItem(value: 1, child: Text('Casado')),
          DropdownMenuItem(value: 2, child: Text('Divorciado')),
          DropdownMenuItem(value: 3, child: Text('Viúvo')),
        ];
      case 'Nacionalidade':
        return const [
          DropdownMenuItem(value: 0, child: Text('Brasileiro')),
          DropdownMenuItem(value: 1, child: Text('Estrangeiro')),
        ];
      case 'Cor/Raca/Etnia':
        return const [
          DropdownMenuItem(value: 0, child: Text('Branco')),
          DropdownMenuItem(value: 1, child: Text('Pardo')),
          DropdownMenuItem(value: 2, child: Text('Negro')),
          DropdownMenuItem(value: 3, child: Text('Amarelo')),
          DropdownMenuItem(value: 4, child: Text('Indígena')),
        ];
      case 'Escolaridade':
        return const [
          DropdownMenuItem(value: 0, child: Text('Ensino Médio')),
          DropdownMenuItem(value: 1, child: Text('Graduação')),
          DropdownMenuItem(value: 2, child: Text('Pós-Graduação')),
          DropdownMenuItem(value: 3, child: Text('Mestrado')),
          DropdownMenuItem(value: 4, child: Text('Doutorado')),
        ];
      case 'Cargo':
        return const [
          DropdownMenuItem(value: 0, child: Text('Docente')),
          DropdownMenuItem(value: 1, child: Text('Coordenador(a) de Curso')),
          DropdownMenuItem(value: 2, child: Text('Diretor(a) Acadêmico')),
          DropdownMenuItem(value: 3, child: Text('Funcionário Administrativo')),
          DropdownMenuItem(value: 4, child: Text('Pesquisador(a)')),
          DropdownMenuItem(value: 5, child: Text('Serviços de Limpeza')),
          DropdownMenuItem(value: 6, child: Text('Funcionário de Refeitório')),
          DropdownMenuItem(value: 7, child: Text('Bibliotecario(a)')),
        ];
      default:
        return [];
    }
  }
  // #endregion

  // #region TextInput
  String generateRandomMatricula(String field) {
    final random = Random();
    if (field == 'NumeroMatricula') {
      return 'MAT-${random.nextInt(1000000).toString().padLeft(6, '0')}';
    } else {
      return 'DOC-${random.nextInt(1000000).toString().padLeft(6, '0')}';
    }
  }

  Widget? buildSuffixIcon(
      String field, TextEditingController customController) {
    switch (field) {
      case 'CPF':
        return ValueListenableBuilder<bool>(
          valueListenable: isCpfValid,
          builder: (context, isValid, child) {
            if (customController.text.isEmpty) {
              return const Icon(
                Icons.info,
                color: Colors.grey,
              );
            }
            return Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red,
            );
          },
        );
      case 'Email':
      case 'EmailResponsavel':
        return ValueListenableBuilder<bool>(
          valueListenable: isEmailValid,
          builder: (context, isValid, child) {
            if (customController.text.isEmpty) {
              return const Icon(
                Icons.info,
                color: Colors.grey,
              );
            }
            return Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red,
            );
          },
        );
      case 'CNPJ':
        return ValueListenableBuilder<bool>(
          valueListenable: isCNPJValid,
          builder: (context, isValid, child) {
            if (customController.text.isEmpty) {
              return const Icon(
                Icons.info,
                color: Colors.grey,
              );
            }
            return Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red,
            );
          },
        );
      default:
        return null;
    }
  }

  String? Function(String?)? getValidator(String field) {
    switch (field.toLowerCase()) {
      case 'cpf':
        return (value) {
          if (!InputValidators.validateCpfLogic(value!)) {
            return 'CPF inválido';
          }
          return null;
        };
      case 'email':
      case 'emailresponsavel':
        return (value) {
          if (!InputValidators.validateEmailLogic(value!)) {
            return 'Email inválido';
          }
          return null;
        };
      case 'cnpj':
        return (value) {
          if (!InputValidators.validateCnpjLogic(value!)) {
            return 'CNPJ inválido';
          }
          return null;
        };
      default:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo é obrigatório';
          }
          return null;
        };
    }
  }

  Widget buildTextInput(
    String field,
    BuildContext context,
    TextEditingController customController,
    bool enabled, {
    bool disabled = false,
    Widget? suffixIconEndereco,
    BorderRadius? radius,
    EdgeInsets? customPadding,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    String labelText = fieldNames[field] ?? field;
    TextInputType keyboardType = getKeyboardType(field);
    int? maxLength = getMaxLength(field);

    List<TextInputFormatter> inputFormatters = [];
    // Utiliza o validator fornecido ou o padrão obtido de getValidator(field)
    String? Function(String?)? effectiveValidator =
        validator ?? getValidator(field);

    Widget? suffixIcon = buildSuffixIcon(field, customController);

    if (field == 'DataMatricula' ||
        field == 'DataNascimento' ||
        field == 'DataAdmissao') {
      inputFormatters.add(DateTextInputFormatter(
        isDataNascimento: field == 'DataNascimento',
      ));
    }

    return Padding(
      padding: customPadding ?? const EdgeInsets.only(bottom: 12),
      child: CustomInputTextCadastro(
        inputFormatters: inputFormatters,
        borderRadius: radius,
        controller: customController,
        labelText: labelText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enabled: enabled && !disabled,
        suffixIcon: suffixIcon,
        validator: effectiveValidator,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
  // #endregion

  // #region Dropdown
  Widget buildDropdown(
    String field,
    BuildContext context,
    bool enabled,
    Function(int?) onChangedCallback, {
    bool disabled = false,
  }) {
    List<DropdownMenuItem<int>> items = [];

    switch (field) {
      case 'Curso':
        items = cursosDropdownItems;
        break;

      case 'Turma':
        final cursoSelecionado = dropdownValues['Curso'];
        if (cursoSelecionado != null &&
            turmasPorCurso.containsKey(cursoSelecionado)) {
          final turmas = turmasPorCurso[cursoSelecionado];
          items = turmas!.map<DropdownMenuItem<int>>((turma) {
            String periodoName = PeriodoCurso.values[turma['periodo']].name;
            return DropdownMenuItem<int>(
              value: turma['id'],
              child: Text(periodoName),
            );
          }).toList();
        }
        break;
      default:
        items = getDropdownItems(field);
    }

    String labelText = fieldNames[field] ?? field;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: selectedValues[field],
        items: items,
        iconSize: 20,
        onChanged: (newValue) {
          onChangedCallback(newValue);
        },
        decoration: InputDecoration(
          enabled: enabled && !isLoading && !disabled,
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
  // #endregion

  // #region Faculdade
  Widget buildCamposFaculdadeECurso(BuildContext context, isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFaculdadeInput(context),
        buildCursosDropdown(context, !isLoading)
      ],
    );
  }

  void abrirTelaFaculdades(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.buttonColor,
            ),
          );
        },
      );

      final faculdades = (await ApiService().listarFaculdades())
          .map((faculdade) => faculdade as Map<String, dynamic>)
          .toList();

      Navigator.pop(context);

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
        faculdadeSelecionadaNotifier.value = selecionada;
        cursoSelecionadoNotifier.value = null;
        cursosDropdownItemsNotifier.value = [];
        dropdownValues['Curso'] = null;
        dropdownValues['Turma'] = null;

        if (selecionada['id'] != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.buttonColor,
                ),
              );
            },
          );

          final cursos = await ApiService().buscarCursosPorFaculdade(
            selecionada['id'],
          );

          Navigator.pop(context);

          if (cursos.isNotEmpty) {
            cursosDropdownItemsNotifier.value = cursos.map((curso) {
              return DropdownMenuItem<int>(
                value: curso['id'],
                child: Text(curso['nome']),
              );
            }).toList();

            turmasPorCurso = {
              for (var curso in cursos) curso['id']: curso['turmas']
            };
          } else {
            cursosDropdownItemsNotifier.value = [];
          }
        }
      }
    } catch (e) {
      Navigator.pop(context);

      print('Erro ao buscar faculdades ou cursos: $e');
      CustomSnackbar.show(context,
          'Erro ao carregar faculdades. Verifique se existe alguma faculdade cadastrada e tente novamente.');
    }
  }

  Widget buildFaculdadeInput(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: faculdadeSelecionadaNotifier,
        builder: (context, faculdadeSelecionada, child) {
          return GestureDetector(
            onTap: () => abrirTelaFaculdades(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    faculdadeSelecionada.isNotEmpty
                        ? faculdadeSelecionada['nome']
                        : 'Selecione uma Faculdade',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (faculdadeSelecionada.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        faculdadeSelecionadaNotifier.value = {};
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCursosDropdown(
    BuildContext context,
    bool enabled, {
    bool disabled = false,
  }) {
    return ValueListenableBuilder<List<DropdownMenuItem<int>>>(
      valueListenable: cursosDropdownItemsNotifier,
      builder: (context, cursosDropdownItems, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<int>(
            value: cursoSelecionadoNotifier.value,
            onChanged: (newValue) {
              if (newValue != null) {
                cursoSelecionadoNotifier.value = newValue;
                onCursoSelecionado(newValue);
              }
            },
            items: cursosDropdownItems,
            decoration: InputDecoration(
              enabled: enabled && !isLoading && !disabled,
              labelText: 'Selecione o Curso',
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
      },
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
  // #endregion

  // #region Adicionar Turma ao Aluno
  void onCursoSelecionado(int? cursoId) {
    if (cursoId != null) {
      cursoSelecionadoNotifier.value = cursoId;

      if (turmasPorCurso.containsKey(cursoId)) {
        final turmas = turmasPorCurso[cursoId];
        turmasDropdownItemsNotifier.value =
            turmas!.map<DropdownMenuItem<int>>((turma) {
          String periodoName = PeriodoCurso.values[turma['periodo']].name;
          return DropdownMenuItem<int>(
            value: turma['id'],
            child: Text(periodoName),
          );
        }).toList();
      } else {
        turmasDropdownItemsNotifier.value = [];
      }
    }
  }

  Widget buildTurmasDropdown(
    BuildContext context,
    bool enabled, {
    bool disabled = false,
  }) {
    return ValueListenableBuilder<List<DropdownMenuItem<int>>>(
      valueListenable: turmasDropdownItemsNotifier,
      builder: (context, turmasDropdownItems, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<int>(
            value: dropdownValues['Turma'] as int?,
            onChanged: (newValue) {
              dropdownValues['Turma'] = newValue;
            },
            items: turmasDropdownItems,
            decoration: InputDecoration(
              enabled: enabled && !isLoading && !disabled,
              labelText: 'Selecione a Turma',
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
      },
    );
  }
  // #endregion

  // #region Adicionar Cursos/Disciplias
  Widget buildListInput(
    BuildContext context, {
    required String label,
    required bool enabled,
    bool disabled = false,
    required TextEditingController controller,
    required List<String> itemsDisponiveis,
    required List<String> filteredItems,
    required Function(String) onAddItem,
    required Function(String) onRemoveItem,
    required VoidCallback onRemoveAll,
    required Function(String) onFilter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          cursorColor: AppColors.backgroundBlueColor,
          maxLength: 50,
          controller: controller,
          enabled: enabled && !isLoading && !disabled,
          onChanged: (value) {
            onFilter(value);
          },
          decoration: InputDecoration(
            counterText: '',
            labelText: label,
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
        if (controller.text.isNotEmpty && filteredItems.isNotEmpty)
          Card(
            color: AppColors.backgroundWhiteColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            margin: const EdgeInsets.only(top: 5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () => onAddItem(item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget buildSelectedItems(
    BuildContext context, {
    required String label,
    required List<String> itemsSelecionados,
    required Function(String) onRemoveItem,
    required VoidCallback onRemoveAll,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: itemsSelecionados.map((item) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 110,
                ),
                child: Chip(
                  label: GestureDetector(
                    onTap: () {
                      CustomSnackbar.show(
                        context,
                        item,
                        backgroundColor: AppColors.socialButtonColor,
                      );
                    },
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  backgroundColor: AppColors.lightGreyColor,
                  deleteIcon: const Icon(Icons.close, color: Colors.red),
                  onDeleted: () => onRemoveItem(item),
                ),
              );
            }).toList(),
          ),
          if (itemsSelecionados.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRemoveAll,
                child: const Text(
                  'Remover tudo',
                  style: TextStyle(color: AppColors.buttonColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
  // #endregion

  Future<void> searchAddress({
    required BuildContext context,
    required TextEditingController cepController,
    required TextEditingController logradouroController,
    required TextEditingController bairroController,
    required TextEditingController cidadeController,
    required TextEditingController estadoController,
    required ValueNotifier<bool> isLoading,
  }) async {
    isLoading.value = true;

    final cep = cepController.text.replaceAll('-', '').trim();
    if (cep.isEmpty || cep.length != 8) {
      CustomSnackbar.show(context, 'Por favor, insira um CEP válido.');
      isLoading.value = false;
      return;
    }

    final address = await ApiService().fetchAddressByCep(cep);
    if (address != null) {
      logradouroController.text = address['logradouro'] ?? '';
      bairroController.text = address['bairro'] ?? '';
      cidadeController.text = address['localidade'] ?? '';
      estadoController.text = address['uf'] ?? '';
    } else {
      CustomSnackbar.show(context, 'Endereço não encontrado para este CEP.');
    }

    isLoading.value = false;
  }
}
