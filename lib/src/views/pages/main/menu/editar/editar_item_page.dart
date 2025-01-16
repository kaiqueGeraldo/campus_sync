import 'dart:convert';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_endereco_form.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditarItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final String titulo;
  final String endpoint;
  final void Function(Map<String, dynamic>) onSave;

  const EditarItemPage({
    super.key,
    required this.item,
    required this.onSave,
    required this.titulo,
    required this.endpoint,
  });

  @override
  State<EditarItemPage> createState() => _EditarItemPageState();
}

class _EditarItemPageState extends State<EditarItemPage> {
  late Map<String, TextEditingController> controllers;
  late CadastroController controller;
  final GlobalKey<FormState> campoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> enderecoFormKey = GlobalKey<FormState>();
  String cursosError = '';
  bool _isLoading = false;
  final ValueNotifier<bool> _isLoadingController = ValueNotifier(false);

  bool isCampoExpanded = true;
  bool isEnderecoExpanded = true;

  Future<void> updateEntity(String endpoint, int id,
      Map<String, TextEditingController> controllers) async {
    final isCampoValid = campoFormKey.currentState?.validate() ?? false;
    final isEnderecoValid = enderecoFormKey.currentState?.validate() ?? false;

    if (!isCampoValid || !isEnderecoValid) {
      return;
    }

    Uri url;
    if (endpoint == 'Curso') {
      url = Uri.parse('${ApiService.baseUrl}/$endpoint/atualizar-curso/$id');
    } else {
      url = Uri.parse('${ApiService.baseUrl}/$endpoint/$id');
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final cpf = await ApiService().recuperarCPF();

      // Monta o objeto do endereço a partir dos campos relacionados
      final Map<String, dynamic> enderecoAtualizado = {
        for (var campo in camposPorEndpoint[endpoint] ?? [])
          if (campo['key'].contains('Endereco'))
            campo['key']
                .replaceFirst('Endereco', '')
                .toLowerCase(): controllers[
                        'endereco.${campo['key'].replaceFirst('Endereco', '').toLowerCase()}']
                    ?.text ??
                '',
      };

      bool endpointRequiresCpf(String endpoint) {
        List<String> endpointsQuePrecisamCpf = [
          'Colaborador',
          'Faculdade',
        ];

        return endpointsQuePrecisamCpf.contains(endpoint);
      }

      bool endpointRequiresFaculdadeId(String endpoint) {
        List<String> endpointsQuePrecisamFaculdadeId = [
          'Curso',
        ];

        return endpointsQuePrecisamFaculdadeId.contains(endpoint);
      }

      final Map<String, dynamic> payload = {
        'id': widget.item['id'],
        for (var campo in camposPorEndpoint[endpoint] ?? [])
          if (!campo['key'].contains('Endereco'))
            campo['key']: campo['type'] == 'dropdown'
                ? (campo['key'] == 'cargo'
                    ? controllers[campo['key']]?.text ?? ''
                    : int.tryParse(controllers[campo['key']]?.text ?? '') ?? 0)
                : controllers[campo['key']]?.text ?? '',
        if (enderecoAtualizado.isNotEmpty) 'endereco': enderecoAtualizado,
        if (endpointRequiresCpf(endpoint))
          (endpoint == 'Colaborador') ? 'userCPFColaboradores' : 'userCPF': cpf,
        if (endpointRequiresFaculdadeId(endpoint))
          'faculdadeId': widget.item['faculdadeId'],
      };

      print('Payload a ser enviado: $payload');
      print('URL: $url');

      // Envia a requisição PUT para a API
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Atualização realizada com sucesso.');
        widget.onSave(payload);
        CustomSnackbar.show(
          context,
          '${widget.titulo} atualizado com sucesso!',
          backgroundColor: AppColors.successColor,
        );
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(
          context,
          'Erro ao atualizar: ${widget.titulo}. Verifique os dados e tente novamente!',
        );
        print('Erro ao atualizar: ${response.statusCode}');
        print('Resposta: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final Map<String, List<Map<String, dynamic>>> camposPorEndpoint = {
    'Faculdade': [
      {'label': 'Nome', 'key': 'nome', 'type': 'text'},
      {'label': 'Telefone', 'key': 'telefone', 'type': 'text'},
      {
        'label': 'E-mail do Responsável',
        'key': 'emailResponsavel',
        'type': 'text'
      },
      {'label': 'TipoFacul', 'key': 'tipo', 'type': 'dropdown'},
      {'label': 'CEP', 'key': 'EnderecoCEP', 'type': 'text'},
      {'label': 'Logradouro', 'key': 'EnderecoLogradouro', 'type': 'text'},
      {'label': 'Número', 'key': 'EnderecoNumero', 'type': 'text'},
      {'label': 'Bairro', 'key': 'EnderecoBairro', 'type': 'text'},
      {'label': 'Cidade', 'key': 'EnderecoCidade', 'type': 'text'},
      {'label': 'Estado', 'key': 'EnderecoEstado', 'type': 'text'},
    ],
    'Curso': [
      {'label': 'Nome', 'key': 'nome', 'type': 'text'},
      {'label': 'Mensalidade', 'key': 'mensalidade', 'type': 'number'},
    ],
    'Estudante': [
      {'label': 'Nome', 'key': 'nome', 'type': 'text'},
      {'label': 'E-mail', 'key': 'email', 'type': 'text'},
      {'label': 'Telefone', 'key': 'telefone', 'type': 'text'},
      {'label': 'CEP', 'key': 'EnderecoCEP', 'type': 'text'},
      {'label': 'Logradouro', 'key': 'EnderecoLogradouro', 'type': 'text'},
      {'label': 'Número', 'key': 'EnderecoNumero', 'type': 'text'},
      {'label': 'Bairro', 'key': 'EnderecoBairro', 'type': 'text'},
      {'label': 'Cidade', 'key': 'EnderecoCidade', 'type': 'text'},
      {'label': 'Estado', 'key': 'EnderecoEstado', 'type': 'text'},
    ],
    'Colaborador': [
      {'label': 'Nome', 'key': 'nome', 'type': 'text'},
      {'label': 'E-mail', 'key': 'email', 'type': 'text'},
      {'label': 'Telefone', 'key': 'telefone', 'type': 'text'},
      {'label': 'CEP', 'key': 'EnderecoCEP', 'type': 'text'},
      {'label': 'Logradouro', 'key': 'EnderecoLogradouro', 'type': 'text'},
      {'label': 'Número', 'key': 'EnderecoNumero', 'type': 'text'},
      {'label': 'Bairro', 'key': 'EnderecoBairro', 'type': 'text'},
      {'label': 'Cidade', 'key': 'EnderecoCidade', 'type': 'text'},
      {'label': 'Estado', 'key': 'EnderecoEstado', 'type': 'text'},
    ],
  };

  @override
  void initState() {
    super.initState();
    controller = CadastroController();

    // Inicializa os TextEditingControllers
    controllers = {
      for (var campo in camposPorEndpoint[widget.endpoint] ?? [])
        if (campo['key'].contains('Endereco'))
          'endereco.${campo['key'].replaceFirst('Endereco', '').toLowerCase()}':
              TextEditingController(
            text: widget.item['endereco']?[
                        campo['key'].replaceFirst('Endereco', '').toLowerCase()]
                    ?.toString() ??
                '',
          )
        else
          campo['key']: TextEditingController(
            text: widget.item[campo['key']]?.toString() ?? '',
          ),
    };

    // Define os valores iniciais para os dropdowns
    controller.selectedValues = {
      for (var campo in camposPorEndpoint[widget.endpoint] ?? [])
        if (campo['type'] == 'dropdown' && widget.item[campo['key']] != null)
          campo['label']: widget.item[campo['key']],
    };

    controller.dropdownValues = {
      for (var campo in camposPorEndpoint[widget.endpoint] ?? [])
        if (campo['type'] == 'dropdown') ...{
          campo['label']: controller.getDropdownItems(campo['label'])
        }
    };
    print('Dropdown values: ${controller.dropdownValues}');
  }

  Widget _buildCustomExpansionCards() {
    final campos = camposPorEndpoint[widget.endpoint] ?? [];

    // Filtra os campos que não são de endereço
    final camposSemEndereco =
        campos.where((campo) => !campo['key'].contains('Endereco')).toList();

    return Column(
      children: [
        CustomExpansionCard(
          formKey: campoFormKey,
          title: 'Dados da ${widget.titulo}',
          icon: Icons.info,
          initiallyExpanded: true,
          onExpansionChanged: (expanded) {
            setState(() {
              isCampoExpanded = expanded;
            });
          },
          children: camposSemEndereco.map((campo) {
            if (campo['type'] == 'dropdown') {
              return _buildDropdownField(
                label: campo['label'],
                key: campo['key'],
                values: controller.dropdownValues[campo['label']] ?? [],
              );
            } else {
              return controller.buildTextInput(
                campo['label'],
                context,
                controllers[campo['key']]!,
                true,
              );
            }
          }).toList(),
        ),
        if (widget.endpoint == 'Faculdade' ||
            widget.endpoint == 'Estudante' ||
            widget.endpoint == 'Colaborador')
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
                cepController: controllers['endereco.cep']!,
                logradouroController: controllers['endereco.logradouro']!,
                numeroController: controllers['endereco.numero']!,
                bairroController: controllers['endereco.bairro']!,
                cidadeController: controllers['endereco.cidade']!,
                estadoController: controllers['endereco.estado']!,
                isLoadingNotifier: _isLoadingController,
                isLoading: _isLoadingController.value,
                onSearchPressed: () async {
                  _isLoadingController.value = true;

                  // Verifique se os controladores estão presentes
                  final cepController = controllers['endereco.cep'];
                  final logradouroController =
                      controllers['endereco.logradouro'];
                  final bairroController = controllers['endereco.bairro'];
                  final cidadeController = controllers['endereco.cidade'];
                  final estadoController = controllers['endereco.estado'];

                  if (cepController != null &&
                      logradouroController != null &&
                      bairroController != null &&
                      cidadeController != null &&
                      estadoController != null) {
                    await controller.searchAddress(
                      context: context,
                      cepController: cepController,
                      logradouroController: logradouroController,
                      bairroController: bairroController,
                      cidadeController: cidadeController,
                      estadoController: estadoController,
                      isLoading: _isLoadingController,
                    );
                  } else {
                    print("Erro: Um ou mais controladores estão nulos.");
                  }

                  _isLoadingController.value = false;
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String key,
    required List<DropdownMenuItem<int>> values,
  }) {
    print('Dropdown items for $label: ${controller.getDropdownItems(label)}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          enabled: !_isLoading,
          labelText: label,
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
        value: (controller.selectedValues[label] is String)
            ? int.tryParse(controller.selectedValues[label] as String)
            : controller.selectedValues[label] as int?,
        items: values,
        onChanged: (newValue) {
          setState(() {
            controller.selectedValues[key] = newValue;
            controllers[key]?.text = newValue.toString();
          });
        },
      ),
    );
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
          title: Text('Editar ${widget.titulo}'),
          shadowColor: Colors.black,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCustomExpansionCards(),
                      CustomButton(
                        text: 'Atualizar',
                        isLoading: _isLoading,
                        onPressed: () {
                          final id = widget.item['id'];
                          print('ID: ${widget.item['id']}');
                          updateEntity(widget.endpoint, id, controllers);
                        },
                      )
                    ],
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
