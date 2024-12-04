import 'package:flutter/material.dart';

class CadastroEstudantePage extends StatefulWidget {
  final String endpoint;
  const CadastroEstudantePage({super.key, required this.endpoint, required Map<String, dynamic> initialData});

  @override
  State<CadastroEstudantePage> createState() => _CadastroEstudantePageState();
}

class _CadastroEstudantePageState extends State<CadastroEstudantePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}