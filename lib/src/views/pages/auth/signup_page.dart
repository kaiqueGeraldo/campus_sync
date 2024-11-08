import 'package:campus_sync/src/controllers/auth/signup_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text.dart';
import 'package:campus_sync/src/views/components/custom_social_button.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignUpController(context: context);

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
                const SizedBox(
                  height: 200,
                  width: 200,
                  child: Image(image: AssetImage('assets/images/logo.png')),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    'Create your Account',
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
                        controller: controller.usernameController,
                        hintText: 'Username',
                        keyboardType: TextInputType.name,
                        maxLength: 50,
                        validator: controller.validateUsername,
                      ),
                      const SizedBox(height: 20),
                      CustomInputText(
                        controller: controller.cpfController,
                        hintText: 'CPF',
                        keyboardType: TextInputType.number,
                        validator: controller.validateCpf,
                      ),
                      const SizedBox(height: 20),
                      CustomInputText(
                        controller: controller.emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.obscurePassword,
                        builder: (context, obscure, _) {
                          return CustomInputText(
                            controller: controller.passwordController,
                            hintText: 'Password',
                            isPassword: true,
                            obscureText: obscure,
                            onSuffixIconPressed:
                                controller.togglePasswordVisibility,
                            keyboardType: TextInputType.text,
                            maxLength: 30,
                            validator: controller.validatePassword,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.obscurePassword,
                        builder: (context, obscure, _) {
                          return CustomInputText(
                            controller: controller.confirmPasswordController,
                            hintText: 'Confirm Password',
                            isPassword: false,
                            obscureText: obscure,
                            keyboardType: TextInputType.text,
                            maxLength: 30,
                            validator: controller.validateConfirmPassword,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isLoading,
                        builder: (context, isLoading, _) {
                          return CustomButton(
                            text: 'Sign Up',
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
                              'or sign in with',
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
