import 'package:campus_sync/src/controllers/main/menu/entidade_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/pages/main/menu/listagem_page.dart';
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
        .where(
          (item) =>
              item.title != 'Configurações' &&
              item.title != 'Universidade' &&
              item.title != 'Conta',
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: filteredMenuItems.length,
          itemBuilder: (context, index) {
            final item = filteredMenuItems[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SizedBox(
                height: 170,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.backgroundBlueColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 30,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: FutureBuilder<int>(
                              future:
                                  ApiService().fetchItemCount(item.endpoint),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Carregando...",
                                    style: TextStyle(color: Colors.white),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Text(
                                    "Erro ao carregar",
                                    style: TextStyle(color: Colors.red),
                                  );
                                } else {
                                  if (snapshot.data == 1) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            "${snapshot.data ?? 0}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "cadastrado",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            "${snapshot.data ?? 0}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "cadastrados",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () async {
                              final controller =
                                  EntidadeController(item.endpoint);
                              await controller.initialize();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListagemPage(
                                    endpoint: item.endpoint,
                                    fieldMapping: controller.fieldMapping,
                                    cameFromHome: true,
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.arrow_right_alt,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Detalhes",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
