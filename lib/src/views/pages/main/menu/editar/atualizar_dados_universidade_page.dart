import 'dart:convert';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/menu/cadastro_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/cadastro/custom_expansion_card.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_input_text_cadastro.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtualizarDadosUniversidadePage extends StatefulWidget {
  final String endpoint;

  const AtualizarDadosUniversidadePage({
    super.key,
    required this.endpoint,
  });

  @override
  State<AtualizarDadosUniversidadePage> createState() =>
      _AtualizarDadosUniversidadePageState();
}

class _AtualizarDadosUniversidadePageState
    extends State<AtualizarDadosUniversidadePage> {
  late CadastroController controller;
  bool _isLoading = false;
  final TextEditingController nomeUniversidadeController =
      TextEditingController();
  final TextEditingController cnpjUniversidadeController =
      TextEditingController();
  final TextEditingController contatoUniversidadeController =
      TextEditingController();

  bool isDadosUniversidadeExpanded = true;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = CadastroController();
    _loadUserData();
  }

  @override
  void dispose() {
    nomeUniversidadeController.dispose();
    cnpjUniversidadeController.dispose();
    contatoUniversidadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService().fetchUserProfile(context);
    try {
      if (userData['universidadeNome'] != null &&
              userData['universidadeNome'].isNotEmpty ||
          userData['universidadeCNPJ'] != null &&
              userData['universidadeCNPJ'].isNotEmpty ||
          userData['universidadeContatoInfo'] != null &&
              userData['universidadeContatoInfo'].isNotEmpty) {
                
        if (!mounted) return;

        setState(() {
          nomeUniversidadeController.text = userData['universidadeNome'] ?? '';
          cnpjUniversidadeController.text = userData['universidadeCNPJ'] ?? '';
          contatoUniversidadeController.text =
              userData['universidadeContatoInfo'] ?? '';
          _isDataLoaded = true;
        });
      } else {
        if (!mounted) return;

        setState(() {
          nomeUniversidadeController.text = '';
          cnpjUniversidadeController.text = '';
          contatoUniversidadeController.text = '';
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _updateDados() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String? cpf = prefs.getString('userCpf');
    String? email = prefs.getString('userEmail');
    String? nome = prefs.getString('userNome');

    await prefs.setString(
        'userUniversidadeNome', nomeUniversidadeController.text);
    await prefs.setString(
        'userUniversidadeCNPJ', cnpjUniversidadeController.text);
    await prefs.setString(
        'userUniversidadeContato', contatoUniversidadeController.text);

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
            'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/User/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cpf': cpf,
          'nome': nome,
          'email': email,
          'universidadeNome': nomeUniversidadeController.text,
          'universidadeCNPJ': cnpjUniversidadeController.text,
          'universidadeContatoInfo': contatoUniversidadeController.text,
        }),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        CustomSnackbar.show(context, 'Universidade atualizada com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(
          context,
          'Erro ao atualizar universidade: ${response.body}',
          backgroundColor: AppColors.errorColor,
        );
      }
    } catch (e) {
      print('Erro ao atualizar universidade: $e');
      CustomSnackbar.show(context, 'Erro ao atualizar universidade: $e',
          backgroundColor: AppColors.errorColor);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isDadosEntidadeExpanded = true;

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
          title: Text('Configurar ${widget.endpoint}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: _isDataLoaded
                ? Column(
                    children: [
                      CustomExpansionCard(
                        title: 'Dados da Universidade',
                        icon: Icons.account_balance,
                        initiallyExpanded: isDadosEntidadeExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            isDadosEntidadeExpanded = expanded;
                          });
                        },
                        children: [
                          controller.buildTextInput(
                            'UniversidadeNome',
                            context,
                            nomeUniversidadeController,
                            !_isLoading,
                          ),
                          controller.buildTextInput(
                            'UniversidadeCNPJ',
                            context,
                            cnpjUniversidadeController,
                            !_isLoading,
                          ),
                          controller.buildTextInput(
                            'UniversidadeContatoInfo',
                            context,
                            contatoUniversidadeController,
                            !_isLoading,
                          ),
                        ],
                      ),
                      CustomButton(
                        text: _isLoading ? '' : 'Atualizar Dados',
                        isLoading: _isLoading,
                        onPressed: () {
                          if (!_isLoading) {
                            _updateDados();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : const LinearProgressIndicator(
                    backgroundColor: AppColors.lightGreyColor,
                    color: AppColors.buttonColor,
                    valueColor: AlwaysStoppedAnimation(AppColors.buttonColor),
                    minHeight: 8,
                  ),
          ),
        ),
      ),
    );
  }
}
