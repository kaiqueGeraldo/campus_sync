import 'dart:typed_data';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/initial_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/views/pages/main/about_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/entidade_page.dart';
import 'package:campus_sync/src/views/pages/main/home_page.dart';
import 'package:campus_sync/src/views/pages/main/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialPage extends StatefulWidget {
  final bool cameFromSignIn;
  const InitialPage({super.key, required this.cameFromSignIn});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  int _indexAtual = 1;

  List<Widget> telas = [
    const HomePage(),
    const MenuPage(),
    const AboutPage(),
  ];

  String userName = 'Usuário';
  String userEmail = '';
  Uint8List? userImageBytes;
  bool isLoading = true;

  late Map? arguments;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final controller = InitialController(context: context);
    final userData = await controller.getUserData(arguments: arguments);

    setState(() {
      userName = userData['userName'];
      userEmail = userData['userEmail'];
      userImageBytes = userData['userImageBytes'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection || isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: Center(
            child: CircularProgressIndicator(
          color: AppColors.buttonColor,
        )),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () => _loadUserData(), isLoading: false);
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.backgroundWhiteColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.backgroundWhiteColor,
                child: userImageBytes != null
                    ? ClipOval(
                        child: Image.memory(
                          userImageBytes!,
                          fit: BoxFit.cover,
                          width: 72,
                          height: 72,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 50.0,
                      ),
              ),
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              decoration:
                  const BoxDecoration(color: AppColors.backgroundBlueColor),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ...drawerMenuItems
                .where((item) =>
                    item.title != 'Universidade' && item.title != 'Conta')
                .map(
                  (item) => ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntidadePage(
                            titulo: item.title,
                            endpoint: item.endpoint,
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('CampusSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadUserData(),
            tooltip: 'Atualizar',
          ),
          PopupMenuButton<int>(
            color: AppColors.backgroundWhiteColor,
            onSelected: (int result) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onTap: () async {
                  await InitialController(context: context).logout();
                },
                value: 1,
                child: const Text(
                  'Sair da conta',
                  style: TextStyle(
                    color: AppColors.buttonColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: telas[_indexAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexAtual,
        onTap: (index) {
          setState(() {
            _indexAtual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundBlueColor,
        selectedItemColor: AppColors.textColor,
        unselectedItemColor: AppColors.unselectedColor,
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Menu',
            icon: Icon(Icons.business_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Sobre o App',
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
