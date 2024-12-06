import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class DetalhesPage extends StatelessWidget {
  final String endpoint;

  const DetalhesPage(this.endpoint, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text("Detalhes $endpoint"),
      ),
      body: Center(
        child: Text("Detalhes para $endpoint"),
      ),
    );
  }
}
