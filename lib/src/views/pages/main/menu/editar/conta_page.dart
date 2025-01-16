import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/auth/signin_page.dart';
import 'package:campus_sync/src/views/pages/main/not_found_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ContaPage extends StatefulWidget {
  const ContaPage({super.key});

  @override
  State<ContaPage> createState() => _ContaPageState();
}

class _ContaPageState extends State<ContaPage> {
  String userNome = 'Carregando...';
  Uint8List? userImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNome = prefs.getString('userNome') ?? 'Usuário';
      _loadImagemUser();
    });
  }

  Future<void> _loadImagemUser() async {
    try {
      final userData = await ApiService().fetchUserProfile(context);

      if (userData['urlImagem'] != null && userData['urlImagem'].isNotEmpty) {
        setState(() {
          userImageBytes = base64Decode(userData['urlImagem']);
        });
      } else {
        if (!mounted) return;
        setState(() {
          userImageBytes = null;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  void _sessaoExpirada() {
    customShowDialog(
      context: context,
      title: 'Ao na sessão',
      content: 'Erro ao recuperar dados da sua sessão. Faça login novamente',
      confirmText: 'OK',
      onConfirm: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    bool isLoading = false;

    void showLoadingOverlay() {
      isLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.7,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
            CircularProgressIndicator(color: AppColors.buttonColor),
          ],
        ),
      );
    }

    void hideLoadingOverlay() {
      if (isLoading) {
        Navigator.of(context).pop();
        isLoading = false;
      }
    }

    await ApiService().fetchUserProfile(context);

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String? nome = prefs.getString('userNome');

    if (token == null) {
      return _sessaoExpirada();
    }

    customShowDialog(
      context: context,
      title: 'Excluir conta',
      content:
          'Tem certeza que deseja excluir sua conta $nome? Não será possível recuperá-la depois.',
      cancelText: 'Cancelar',
      onCancel: () => Navigator.pop(context),
      confirmText: 'Sim',
      onConfirm: () async {
        customShowDialog(
          context: context,
          title: 'Confirmação Dupla',
          content:
              'Por favor, confirme novamente que deseja excluir sua conta.',
          cancelText: 'Cancelar',
          onCancel: () => Navigator.pop(context),
          confirmText: 'Confirmar',
          onConfirm: () async {
            showLoadingOverlay();
            try {
              final response = await http.delete(
                Uri.parse('${ApiService.baseUrl}/User'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );

              hideLoadingOverlay();

              if (response.statusCode == 200 || response.statusCode == 204) {
                prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
                CustomSnackbar.show(context, 'Conta excluída com sucesso.');
              } else if (response.statusCode == 401) {
                _sessaoExpirada();
              } else {
                CustomSnackbar.show(
                  context,
                  'Erro ao excluir conta: ${response.statusCode} - ${response.body.replaceAll('{"message":', '').replaceAll('}', '').replaceAll('"', '')}',
                );
              }
            } catch (e) {
              hideLoadingOverlay();
              CustomSnackbar.show(
                  context, 'Erro ao processar a requisição. Tente novamente.');
            }
          },
        );
      },
    );
  }

  Widget _buildBackgroundShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
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

    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Conta'),
        elevation: 4,
        shadowColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 50),
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(35),
                              bottomRight: Radius.circular(35),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -40,
                                right: -50,
                                child: _buildBackgroundShape(
                                    Colors.blue.shade600, 150),
                              ),
                              Positioned(
                                top: 70,
                                left: 110,
                                child: _buildBackgroundShape(
                                    Colors.blue.shade600, 100),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 110,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              AppColors.backgroundWhiteColor,
                                          child: userImageBytes != null
                                              ? ClipOval(
                                                  child: Image.memory(
                                                    userImageBytes!,
                                                    fit: BoxFit.cover,
                                                    width: 110,
                                                    height: 110,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 80,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        userNome,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          left: 30,
                          right: 30,
                          child: FutureBuilder<String?>(
                            future: ApiService().recuperarToken(),
                            builder: (context, tokenSnapshot) {
                              if (tokenSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoadingContainer(); // Um contêiner com tamanho fixo enquanto carrega
                              } else if (tokenSnapshot.hasError ||
                                  tokenSnapshot.data == null) {
                                return _buildErrorContainer(
                                    'Erro ao recuperar o token');
                              } else {
                                final token = tokenSnapshot.data!;
                                return FutureBuilder<Map<String, int>>(
                                  future: ApiService().fetchAchievements(token),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildLoadingContainer();
                                    } else if (snapshot.hasError) {
                                      return _buildErrorContainer(
                                          'Erro ao carregar conquistas');
                                    } else {
                                      final achievements = snapshot.data!;
                                      return _buildAchievementsContainer(
                                        achievements,
                                        context,
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Acesso ilimitado a todos os recursos do App",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Desbloqueie todos os incríveis recusos de nosso app. Aproveite a experiência por completo e aumente sua produtividade",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotFoundPage(),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blueAccent,
                              ),
                              child: const Text("Desbloquear"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sobre o Desenvolvedor do App",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Seção "Sobre o Desenvolvedor"
                  _buildSobreDesenvolvedorSection(),
                  const SizedBox(height: 30),
                  // Seção de tecnologias utilizadas
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tecnologias Utilizadas",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTecnologiasSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColors.lightGreyColor,
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: const Text('Excluir Conta'),
                    onTap: () {
                      _deleteUser();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para exibir os itens de conquista
  Widget _buildAchievementItem(
    String title,
    int currentValue,
    int targetValue,
    String achievementImagePath,
    String achievementDescription,
    BuildContext context,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (currentValue >= targetValue) {
              CustomSnackbar.show(context, achievementDescription,
                  backgroundColor: AppColors.successColor);
            } else {
              null;
            }
          },
          child: currentValue >= targetValue
              ? Image.asset(achievementImagePath, width: 45, height: 45)
              : Column(
                  children: [
                    Text(
                      '$currentValue/$targetValue',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // Função para exibir um contêiner de carregamento com tamanho fixo
  Widget _buildLoadingContainer() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.darkGreyColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator(color: Colors.blue)),
    );
  }

// Função para exibir uma mensagem de erro com tamanho fixo
  Widget _buildErrorContainer(String message) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.darkGreyColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: Text(message)),
    );
  }

// Função para exibir o contêiner com as conquistas carregadas
  Widget _buildAchievementsContainer(
      Map<String, int> achievements, BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.darkGreyColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAchievementItem(
            'Primeira\nfaculdade criada!',
            achievements['facultiesCreated'] ?? 0,
            1,
            'assets/images/achievement.png',
            'Conquista: Primeira faculdade criada!',
            context,
          ),
          _buildAchievementItem(
            'Cadastre\n5 cursos',
            achievements['coursesCreated'] ?? 0,
            5,
            'assets/images/achievement.png',
            'Conquista: Cadastre 5 cursos!',
            context,
          ),
          _buildAchievementItem(
            'Realize 100\nmatrículas',
            achievements['enrollmentsCompleted'] ?? 0,
            100,
            'assets/images/achievement.png',
            'Conquista: Realize 100 matrículas!',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildSobreDesenvolvedorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 20,
                    left: -40,
                    child: _buildBackgroundShape(Colors.blue.shade400, 80),
                  ),
                  Positioned(
                    top: -10,
                    right: -20,
                    child: _buildBackgroundShape(Colors.blue.shade300, 100),
                  ),
                  Positioned(
                    bottom: -20,
                    right: -30,
                    child: _buildBackgroundShape(Colors.blue.shade700, 90),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              AssetImage('assets/images/developer_photo.png'),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon(
                              'assets/images/linkedin_icon.png',
                              "https://www.linkedin.com/in/kaique-geraldo/",
                              "LINKEDIN",
                            ),
                            const SizedBox(height: 10),
                            _buildSocialIcon(
                              'assets/images/github_icon.png',
                              "https://github.com/kaiqueGeraldo",
                              "GITHUB",
                            ),
                            const SizedBox(height: 10),
                            _buildSocialIcon(
                              'assets/images/email_icon.png',
                              "mailto:kaiique2404@gmail.com?subject=Solicitação%20de%20Informações&body=Olá,%20gostaria%20de%20mais%20informações%20sobre%20seus%20serviços.",
                              "EMAIL",
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
          const SizedBox(width: 15),
          const Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá! Meu nome é Kaique Santos.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sou apaixonado por tecnologia e desenvolvimento de software. Este app foi uma oportunidade de aplicar meu conhecimento em Flutter e ASP.NET Core para criar algo incrível. Espero que goste do resultado!",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String imageIcon, String url, String label) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(url));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imageIcon, width: 20, height: 20),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTecnologiasSection() {
    final tecnologias = [
      {"image": "assets/images/flutter_icon.png", "name": "Flutter"},
      {"image": "assets/images/dotnet_icon.png", "name": "ASP.NET Core API"},
      {"image": "assets/images/sql_icon.png", "name": "SQL Server"},
      {"image": "assets/images/azure_icon.png", "name": "Azure"},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.start,
      children: tecnologias.map((tecnologia) {
        return SizedBox(
          width: 100,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  tecnologia["image"]!,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tecnologia["name"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
