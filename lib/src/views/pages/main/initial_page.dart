import 'dart:convert';
import 'dart:typed_data';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/controllers/main/initial_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:campus_sync/src/views/pages/main/about_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/entidade_page.dart';
import 'package:campus_sync/src/views/pages/main/home_page.dart';
import 'package:campus_sync/src/views/pages/main/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialPage extends StatefulWidget {
  final bool cameFromSignIn;
  const InitialPage({super.key, required this.cameFromSignIn});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  int _indexAtual = 1;
  final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();
  final GlobalKey<MenuPageState> menuPageKey = GlobalKey<MenuPageState>();
  ValueNotifier<Map<String, int?>> itemCountsNotifier =
      ValueNotifier<Map<String, int?>>({});
  ValueNotifier<Map<String, int?>> itemCountsNotifierMenu =
      ValueNotifier<Map<String, int?>>({});

  String userName = 'Usuário';
  String userEmail = '';
  Uint8List? userImageBytes;
  bool isLoading = false;
  late AnimationController _controller;

  late Map? arguments;

  @override
  void initState() {
    super.initState();
    itemCountsNotifier = ValueNotifier<Map<String, int?>>({});
    itemCountsNotifierMenu = ValueNotifier<Map<String, int?>>({});
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    itemCountsNotifier.dispose();
    itemCountsNotifierMenu.dispose();
    _controller.dispose();
    super.dispose();
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
      isLoading = false;
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
        setState(() {
          userImageBytes = null;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> telas = [
      HomePage(
        itemCountsNotifier: itemCountsNotifier,
        key: homePageKey,
      ),
      MenuPage(
        itemCountsNotifier: itemCountsNotifierMenu,
        key: menuPageKey,
      ),
      const AboutPage(),
    ];

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
            icon: isLoading
                ? RotationTransition(
                    turns: _controller,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 30,
                  ),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });

              final prefs = await SharedPreferences.getInstance();
              final cachedCounts =
                  prefs.getStringList('cachedItemCounts') ?? [];

              await homePageKey.currentState?.updateCacheWithItemCounts();
              final hasMenuUpdates =
                  await menuPageKey.currentState?.fetchCounts() ?? false;

              final updatedCounts =
                  prefs.getStringList('cachedItemCounts') ?? [];

              setState(() {
                isLoading = false;
              });

              if (!hasMenuUpdates &&
                  cachedCounts
                      .toSet()
                      .difference(updatedCounts.toSet())
                      .isEmpty &&
                  updatedCounts
                      .toSet()
                      .difference(cachedCounts.toSet())
                      .isEmpty) {
                CustomSnackbar.show(
                  context,
                  'Nenhuma atualização disponível.',
                  backgroundColor: Colors.blueAccent,
                );
              }
            },
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
