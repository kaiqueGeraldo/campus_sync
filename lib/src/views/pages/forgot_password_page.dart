import 'package:campus_sync/src/controllers/forgot_password_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ForgotPasswordController(context: context);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlueColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlueColor,
        title: const Text('Forgot Password'),
        titleTextStyle:
            const TextStyle(color: AppColors.textColor, fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(
                  height: 200,
                  width: 200,
                  child: Image(image: AssetImage('assets/images/logo.png'))),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Change your Password',
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
                    CustomInputText(
                      controller: controller.confirmCPFController,
                      hintText: 'CPF',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu CPF';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder(
                      valueListenable: controller.verSenha,
                      builder: (context, value, child) {
                        return CustomInputText(
                          controller: controller.novaSenhaController,
                          obscureText: value,
                          hintText: 'Nova Senha',
                          isPassword: true,
                          onSuffixIconPressed: controller.toggleVerSenha,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira uma nova senha';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder(
                      valueListenable: controller.verSenha,
                      builder: (context, value, child) {
                        return CustomInputText(
                          controller: controller.confirmNovaSenhaController,
                          obscureText: value,
                          hintText: 'Confirmar Nova Senha',
                          isPassword: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme a nova senha';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isLoading,
                      builder: (context, isLoading, _) {
                        return CustomButton(
                          text: 'Change Password',
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
