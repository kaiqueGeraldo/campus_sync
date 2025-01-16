import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/auth/forgot_password_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = ForgotPasswordController(context: context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: AppColors.backgroundBlueColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlueColor,
        title: const Text('Esqueci minha Senha'),
        titleTextStyle:
            const TextStyle(color: AppColors.textColor, fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png')),
                    color: Colors.transparent),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Altere sua Senha',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isLoading,
                      builder: (context, isLoading, _) {
                        return CustomInputText(
                          controller: controller.confirmCPFController,
                          hintText: 'CPF',
                          keyboardType: TextInputType.number,
                          enable: !isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu CPF';
                            } else if (!controller.isCpfValid.value) {
                              return 'Por favor, insira um COF válido';
                            }
                            return null;
                          },
                          suffixIcon:
                              controller.confirmCPFController.text.isEmpty
                                  ? const Icon(
                                      Icons.info,
                                      color: Colors.grey,
                                    )
                                  : Icon(
                                      controller.isCpfValid.value
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: controller.isCpfValid.value
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                          onChanged: (value) {
                            setState(() {
                              controller.updateCpfNotifier();
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isLoading,
                      builder: (context, isLoading, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: controller.obscurePassword,
                          builder: (context, obscure, _) {
                            return CustomInputText(
                              controller: controller.novaSenhaController,
                              obscureText: obscure,
                              hintText: 'Nova Senha',
                              isPassword: true,
                              onSuffixIconPressed:
                                  controller.togglePasswordVisibility,
                              enable: !isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira uma nova senha';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isLoading,
                      builder: (context, isLoading, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: controller.obscureConfirmPassword,
                          builder: (context, obscure, _) {
                            return CustomInputText(
                              controller: controller.confirmNovaSenhaController,
                              obscureText: obscure,
                              hintText: 'Confirmar Nova Senha',
                              isPassword: true,
                              onSuffixIconPressed:
                                  controller.toggleConfirmPasswordVisibility,
                              enable: !isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, confirme a nova senha';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isLoading,
                      builder: (context, isLoading, _) {
                        return CustomButton(
                          text: 'Alterar Senha',
                          isLoading: isLoading,
                          onPressed: controller.changePassword,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
