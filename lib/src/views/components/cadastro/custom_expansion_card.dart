import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomExpansionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;

  const CustomExpansionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.children,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightGreyColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        backgroundColor: AppColors.lightGreyColor,
        iconColor: initiallyExpanded ? AppColors.buttonColor : Colors.black,
        leading: Icon(
          icon,
          color: initiallyExpanded ? AppColors.buttonColor : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: initiallyExpanded ? AppColors.buttonColor : Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
