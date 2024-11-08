import 'package:campus_sync/src/controllers/main/initial_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/models/user/user.dart';
import 'package:campus_sync/src/views/pages/main/about_page.dart';
import 'package:campus_sync/src/views/pages/main/menu/entidade_page.dart';
import 'package:campus_sync/src/views/pages/main/home_page.dart';
import 'package:campus_sync/src/views/pages/main/menu_page.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final controller = InitialController(context: context);

    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.backgroundWhiteColor,
        child: FutureBuilder<User>(
          future: controller.fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.buttonColor,
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar dados'));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return Column(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    accountName: Text(user.nome),
                    accountEmail: Text(user.email),
                    decoration: const BoxDecoration(
                        color: AppColors.backgroundBlueColor),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: const Text('Home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ...drawerMenuItems.map(
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
              );
            } else {
              return const Center(child: Text('Nenhum dado disponível'));
            }
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('CampusSync'),
        actions: [
          PopupMenuButton<int>(
            color: AppColors.backgroundWhiteColor,
            onSelected: (int result) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onTap: controller.logout,
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
            label: 'About',
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
