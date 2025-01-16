import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/auth/signup_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text.dart';
import 'package:campus_sync/src/views/components/custom_social_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final SignUpController controller;

  @override
  void initState() {
    super.initState();
    controller = SignUpController(context: context);
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
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundBlueColor,
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    'Criar sua conta',
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
                            controller: controller.usernameController,
                            hintText: 'Nome de usuário',
                            keyboardType: TextInputType.name,
                            maxLength: 50,
                            enable: !isLoading,
                            validator: controller.validateUsername,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isLoading,
                        builder: (context, isLoading, _) {
                          return CustomInputText(
                            controller: controller.cpfController,
                            hintText: 'CPF',
                            keyboardType: TextInputType.number,
                            enable: !isLoading,
                            validator: (value) {
                              return controller.isCpfValid.value
                                  ? null
                                  : 'CPF inválido';
                            },
                            suffixIcon: controller.cpfController.text.isEmpty
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
                          return CustomInputText(
                            controller: controller.emailController,
                            hintText: 'E-mail',
                            keyboardType: TextInputType.emailAddress,
                            enable: !isLoading,
                            validator: (value) {
                              return controller.isEmailValid.value
                                  ? null
                                  : 'E-mail inválido';
                            },
                            suffixIcon: controller.emailController.text.isEmpty
                                ? const Icon(
                                    Icons.info,
                                    color: Colors.grey,
                                  )
                                : Icon(
                                    controller.isEmailValid.value
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: controller.isEmailValid.value
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            onChanged: (value) {
                              setState(() {
                                controller.updateEmailNotifier();
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
                                controller: controller.passwordController,
                                hintText: 'Senha',
                                isPassword: true,
                                obscureText: obscure,
                                onSuffixIconPressed:
                                    controller.togglePasswordVisibility,
                                keyboardType: TextInputType.text,
                                maxLength: 30,
                                enable: !isLoading,
                                validator: controller.validatePassword,
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
                                controller:
                                    controller.confirmPasswordController,
                                hintText: 'Confirme a Senha',
                                isPassword: true,
                                obscureText: obscure,
                                onSuffixIconPressed:
                                    controller.toggleConfirmPasswordVisibility,
                                keyboardType: TextInputType.text,
                                maxLength: 30,
                                enable: !isLoading,
                                validator: controller.validateConfirmPassword,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isLoading,
                        builder: (context, isLoading, _) {
                          return CustomButton(
                            text: 'Cadastrar',
                            isLoading: isLoading,
                            onPressed: controller.register,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            child: Divider(
                              color: AppColors.textColor,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              'ou entre com',
                              style: TextStyle(
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            child: Divider(
                              color: AppColors.textColor,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomSocialButton(
                            assetPath: 'assets/icons/icon_google.svg',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 25),
                          CustomSocialButton(
                            assetPath: 'assets/icons/icon_facebook.svg',
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
