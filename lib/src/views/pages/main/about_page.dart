import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late List<bool> _animations;

  final List<Map<String, dynamic>> aboutItems = [
    {
      'title': 'SOBRE O APP',
      'icon': Icons.phone_android,
      'content': [
        const Text(
          'Este aplicativo foi desenvolvido com o intuito de auxiliar profissionais ou instituições a organizar e controlar o cadastro de sua universidade.',
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 10),
        const Text(
          'Evitamos o uso de propagandas para não prejudicar a usabilidade da ferramenta.',
          style: TextStyle(fontSize: 15),
        ),
      ],
    },
    {
      'title': 'REPORTAR PROBLEMA',
      'icon': Icons.chat,
      'content': [
        const Text(
          "Para relatar problemas, envie um e-mail para 'gestao.campussync.app@gmail.com'.",
          style: TextStyle(fontSize: 15),
        ),
      ],
    },
    {
      'title': 'VERSÃO',
      'icon': Icons.safety_check,
      'content': [
        const Text('version: 1.0.0', style: TextStyle(fontSize: 15)),
      ],
    },
    {
      'title': 'VERSÃO WEB',
      'icon': Icons.laptop,
      'content': [
        const Text(
          'Acesse sua conta de qualquer computador',
          style: TextStyle(fontSize: 15),
        ),
        const Text(
          'Entre no site',
          style: TextStyle(fontSize: 15),
        ),
        GestureDetector(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'https://youtube.com',
              style: TextStyle(color: AppColors.buttonColor, fontSize: 15),
            ),
          ),
        ),
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializando a lista de animações, definindo inicialmente o segundo item como expandido
    _animations = List<bool>.filled(aboutItems.length, false);
    _animations[1] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
              aboutItems.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _animations[index] = !_animations[index];
                    });
                  },
                  child: _buildExpandableContainer(
                    title: aboutItems[index]['title'],
                    icon: aboutItems[index]['icon'],
                    isExpanded: _animations[index],
                    content: aboutItems[index]['content'],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContainer({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isExpanded
                        ? AppColors.buttonColor
                        : AppColors.backgroundBlueColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  icon,
                  color: isExpanded
                      ? AppColors.buttonColor
                      : AppColors.backgroundBlueColor,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: content,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
