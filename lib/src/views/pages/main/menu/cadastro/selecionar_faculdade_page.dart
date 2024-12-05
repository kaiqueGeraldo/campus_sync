import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class SelecionarFaculdadePage extends StatefulWidget {
  final List<Map<String, dynamic>> faculdades;
  final void Function(Map<String, dynamic>) onSelecionar;

  const SelecionarFaculdadePage({
    super.key,
    required this.faculdades,
    required this.onSelecionar,
  });

  @override
  State<SelecionarFaculdadePage> createState() =>
      _SelecionarFaculdadePageState();
}

class _SelecionarFaculdadePageState extends State<SelecionarFaculdadePage> {
  late List<Map<String, dynamic>> faculdadesFiltradas;
  final TextEditingController pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    faculdadesFiltradas = widget.faculdades;
  }

  void _filtrarFaculdades() {
    final query = pesquisaController.text.toLowerCase();
    setState(() {
      faculdadesFiltradas = widget.faculdades
          .where((faculdade) =>
              faculdade['nome'].toLowerCase().contains(query) |
              faculdade['id'].toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Selecionar Faculdade'),
        backgroundColor: AppColors.backgroundBlueColor,
        shadowColor: Colors.black,
        elevation: 4,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.backgroundBlueColor,
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: pesquisaController,
              decoration: InputDecoration(
                hintText: 'Localizar',
                hintStyle: const TextStyle(color: AppColors.darkGreyColor),
                filled: true,
                fillColor: AppColors.backgroundWhiteColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.darkGreyColor),
                  onPressed: _filtrarFaculdades,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.darkGreyColor),
                  onPressed: () {
                    pesquisaController.clear();
                    setState(() {
                      faculdadesFiltradas = widget.faculdades;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _filtrarFaculdades(),
            ),
          ),
          Expanded(
            child: faculdadesFiltradas.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: faculdadesFiltradas.length,
                    itemBuilder: (context, index) {
                      final faculdade = faculdadesFiltradas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: AppColors.lightGreyColor,
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            faculdade['nome'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('ID: ${faculdade['id']}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            widget.onSelecionar(faculdade);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('Nenhuma faculdade encontrada.'),
                  ),
          ),
        ],
      ),
    );
  }
}
