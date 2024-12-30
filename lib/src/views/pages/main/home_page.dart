import 'package:campus_sync/src/controllers/main/menu/entidade_controller.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/models/initial_page/drawer_menu_item.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/pages/main/menu/listagem_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<Map<String, int?>> itemCountsNotifier;

  const HomePage({
    super.key,
    required this.itemCountsNotifier,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Map<String, int?> itemCounts = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadItemCounts();
  }

  Future<void> loadItemCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCounts = prefs.getStringList('cachedItemCounts') ?? [];

    Map<String, int?> tempCounts = {};
    for (var cached in cachedCounts) {
      final parts = cached.split(':');
      if (parts.length == 2) {
        final endpoint = parts[0];
        final count = int.tryParse(parts[1]) ?? 0;
        tempCounts[endpoint] = count;
      }
    }

    if (!mounted) return;

    widget.itemCountsNotifier.value = tempCounts;
  }

  Future<void> updateCacheWithItemCounts() async {
    setState(() {
      isLoading = true;
    });
    print('Iniciando atualização...');
    final prefs = await SharedPreferences.getInstance();
    Map<String, int?> tempCounts = {};

    for (var item in drawerMenuItems) {
      try {
        final count = await ApiService().fetchItemCount(item.endpoint);
        tempCounts[item.endpoint] = count;
      } catch (e) {
        print(
            "Erro ao carregar a contagem de itens para o endpoint ${item.endpoint}: $e");
        tempCounts[item.endpoint] = 0;
      }
    }

    final newCache = tempCounts.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await prefs.setStringList('cachedItemCounts', newCache);

    widget.itemCountsNotifier.value = tempCounts;
    print('Atualização concluida, itens: $tempCounts');

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

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

    return ValueListenableBuilder<Map<String, int?>>(
      valueListenable: widget.itemCountsNotifier,
      builder: (context, itemCounts, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundWhiteColor,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: filteredMenuItems.length,
              itemBuilder: (context, index) {
                final item = filteredMenuItems[index];
                final itemCount = itemCounts[item.endpoint];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: SizedBox(
                    height: 170,
                    child: Card(
                      key: ValueKey(item.endpoint),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppColors.backgroundBlueColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildHeader(item, context),
                            _buildItemCountInfo(itemCount, context),
                            _buildDetailsButton(item, context),
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
      },
    );
  }

  /// Cabeçalho com Ícone e Título
  Widget _buildHeader(item, BuildContext context) {
    return Expanded(
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
    );
  }

  /// Informações sobre itens cadastrados
  Widget _buildItemCountInfo(int? itemCount, BuildContext context) {
    return Expanded(
      flex: 2,
      child: Align(
        alignment: Alignment.center,
        child: isLoading
            ? const Text(
                "Carregando...",
                style: TextStyle(color: Colors.white),
              )
            : itemCount == null || itemCount == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "0",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                      ),
                      Text(
                        "cadastrados",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$itemCount",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                      ),
                      Text(
                        itemCount == 1 ? "cadastrado" : "cadastrados",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                      ),
                    ],
                  ),
      ),
    );
  }

  /// Botão de Detalhes
  Widget _buildDetailsButton(item, BuildContext context) {
    return Expanded(
      flex: 1,
      child: TextButton(
        onPressed: () async {
          final controller = EntidadeController(item.endpoint);
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
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
