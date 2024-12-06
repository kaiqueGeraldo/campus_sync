import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class EditarItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final void Function(Map<String, dynamic>) onSave;

  const EditarItemPage({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditarItemPage> createState() => _EditarItemPageState();
}

class _EditarItemPageState extends State<EditarItemPage> {
  late TextEditingController nomeController;
  late TextEditingController idController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.item['nome']);
    idController = TextEditingController(text: widget.item['id'].toString());
  }

  @override
  void dispose() {
    nomeController.dispose();
    idController.dispose();
    super.dispose();
  }

  void _salvarEdicao() {
    final atualizado = {
      'id': idController.text,
      'nome': nomeController.text,
    };

    widget.onSave(atualizado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Editar Item'),
        backgroundColor: AppColors.backgroundBlueColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
              readOnly: true,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _salvarEdicao,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
