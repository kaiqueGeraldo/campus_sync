import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/pages/main/detalhes_home_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final filteredMenuItems = drawerMenuItems
        .where((item) =>
            item.title != 'Configurações' && item.title != 'Universidade')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredMenuItems.length,
          itemBuilder: (context, index) {
            final item = filteredMenuItems[index];

            return SizedBox(
              height: 130,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.backgroundBlueColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<int>(
                              future:
                                  ApiService().fetchItemCount(item.endpoint),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Carregando...",
                                    style: TextStyle(color: Colors.white70),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Text(
                                    "Erro ao carregar",
                                    style: TextStyle(color: Colors.red),
                                  );
                                } else {
                                  if (snapshot.data == 1) {
                                    return Text(
                                      "${snapshot.data} cadastrado",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                    );
                                  } else {
                                    return Text(
                                      "${snapshot.data ?? 0} cadastrados",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesPage(item.endpoint),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "Detalhes",
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_right_alt,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
