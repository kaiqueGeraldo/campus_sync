import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewDetails;

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: AppColors.lightGreyColor,
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text(
              item['nome'] ?? 'Nome não identificado',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item['universidadeNome'] ??
                  item['faculdadeNome'] ??
                  '${item['cpf']}\n${item['email']}' ??
                  'Nome da Unversidade não definido',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit,
                      color: AppColors.backgroundBlueColor),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          const Divider(),
          TextButton(
            onPressed: onViewDetails,
            child: const Text(
              'Mostrar informações completas',
              style: TextStyle(color: AppColors.buttonColor),
            ),
          )
        ],
      ),
    );
  }
}
