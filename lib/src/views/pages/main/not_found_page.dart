import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Página em Desenvolvimente'),
        shadowColor: Colors.black,
        elevation: 4,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Esta Página ainda está em desenvolvimento. Espere as próximas atualizações para receber as novidades.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
