import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class EnderecoForm extends StatelessWidget {
  final TextEditingController cepController;
  final TextEditingController logradouroController;
  final TextEditingController numeroController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController estadoController;
  final ValueNotifier<bool> isLoadingNotifier;
  final bool isLoading;
  final Future<void> Function()? onSearchPressed;

  EnderecoForm({
    super.key,
    required this.cepController,
    required this.logradouroController,
    required this.numeroController,
    required this.bairroController,
    required this.cidadeController,
    required this.estadoController,
    required this.isLoadingNotifier,
    this.isLoading = false,
    this.onSearchPressed,
  });

  final controllerCadastro = CadastroController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: buildTextInput(
                'EnderecoCEP',
                context,
                cepController,
                !isLoading,
                radius: const BorderRadius.only(
                  bottomRight: Radius.zero,
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.darkGreyColor,
                    size: 20,
                  ),
                  onPressed: () {
                    cepController.clear();
                    logradouroController.clear();
                    bairroController.clear();
                    cidadeController.clear();
                    estadoController.clear();
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 58,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isLoadingNotifier,
                    builder: (context, isLoading, child) {
                      return IconButton(
                        alignment: Alignment.center,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.lightGreyColor,
                                  ),
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(
                                Icons.search,
                                color: AppColors.lightGreyColor,
                              ),
                        onPressed: isLoading ? null : onSearchPressed,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        buildTextInput(
            'EnderecoLogradouro', context, logradouroController, !isLoading),
        buildTextInput('EnderecoNumero', context, numeroController, !isLoading),
        buildTextInput('EnderecoBairro', context, bairroController, !isLoading),
        buildTextInput('EnderecoCidade', context, cidadeController, !isLoading),
        buildTextInput('EnderecoEstado', context, estadoController, !isLoading),
      ],
    );
  }

  Widget buildTextInput(
    String field,
    BuildContext context,
    TextEditingController customController,
    bool enabled, {
    BorderRadius? radius,
    Widget? suffixIcon,
  }) {
    return controllerCadastro.buildTextInput(
      field,
      context,
      customController,
      enabled,
      radius: radius,
      suffixIconEndereco: suffixIcon,
    );
  }
}
