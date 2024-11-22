import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/auth/signin_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text.dart';
import 'package:campus_sync/src/views/components/custom_social_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignInController(context: context);
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () {}, isLoading: false);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBlueColor,
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
                    'Login to your Account',
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
                        controller: controller.emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
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
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: controller.navigateToForgotPassword,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppColors.buttonColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isLoading,
                        builder: (context, isLoading, _) {
                          return CustomButton(
                            text: 'Sign In',
                            isLoading: isLoading,
                            onPressed: controller.login,
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: AppColors.textColor),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: controller.navigateToSignUp,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: AppColors.buttonColor),
                            ),
                          ),
                        ],
                      ),
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
