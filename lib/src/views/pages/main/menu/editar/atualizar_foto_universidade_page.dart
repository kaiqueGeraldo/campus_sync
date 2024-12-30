import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/services/api_service.dart';
import 'package:campus_sync/src/views/components/custom_button.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtualizarFotoUniversidadePage extends StatefulWidget {
  const AtualizarFotoUniversidadePage({super.key});

  @override
  State<AtualizarFotoUniversidadePage> createState() =>
      _AtualizarFotoUniversidadePageState();
}

class _AtualizarFotoUniversidadePageState
    extends State<AtualizarFotoUniversidadePage> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Uint8List? _userImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await ApiService().fetchUserProfile(context);

      if (userData['urlImagem'] != null && userData['urlImagem'].isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _userImageBytes = base64Decode(userData['urlImagem']);
        });

        await _saveUserImage(userData['urlImagem']);
      } else {
        if (!mounted) return;

        setState(() {
          _userImageBytes = null;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserImage(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('userImagem', base64Image);
      print("Imagem salva no SharedPreferences com sucesso!");
    } catch (e) {
      print("Erro ao salvar imagem no SharedPreferences: $e");
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.backgroundWhiteColor,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide.none),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Galeria'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String? cpf = prefs.getString('userCpf');
    String? email = prefs.getString('userEmail');
    String? nome = prefs.getString('userNome');

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await File(_image!.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      print('base64Image: $base64Image');

      final response = await http.put(
        Uri.parse(
            'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/User/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cpf': cpf,
          'nome': nome,
          'email': email,
          'urlImagem': base64Image,
        }),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        CustomSnackbar.show(context, 'Imagem atualizada com sucesso!',
            backgroundColor: AppColors.successColor);
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(
          context,
          'Erro ao atualizar imagem: ${response.body}',
          backgroundColor: AppColors.errorColor,
        );
      }
    } catch (e) {
      print('Erro ao atualizar imagem: $e');
      CustomSnackbar.show(context, 'Erro ao atualizar imagem: $e',
          backgroundColor: AppColors.errorColor);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    if (connectivityService.isCheckingConnection) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        body: Center(
            child: CircularProgressIndicator(
          color: AppColors.buttonColor,
        )),
      );
    }

    if (!connectivityService.isConnected) {
      return OfflinePage(onRetry: () => _loadUserData(), isLoading: false);
    }

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) {
          print('Navegação permitida.');
        } else {
          CustomSnackbar.show(
            context,
            'Navegação bloqueada! Aguarde o carregamento.',
            duration: const Duration(seconds: 2),
          );
          print('Tentativa de navegação bloqueada.');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhiteColor,
        appBar: AppBar(
          title: const Text('Logo da Empresa'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                if (_isLoading)
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.lightGreyColor,
                    color: AppColors.buttonColor,
                    valueColor: AlwaysStoppedAnimation(AppColors.buttonColor),
                    minHeight: 8,
                  )
                else if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.file(
                      File(_image!.path),
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_userImageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.memory(
                      _userImageBytes!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 120,
                    child: Icon(
                      Icons.person,
                      size: 120,
                    ),
                  ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Escolher Imagem',
                  backgroundColor:
                      _isLoading ? Colors.blue.shade300 : AppColors.buttonColor,
                  onPressed: () {
                    if (!_isLoading && !_isLoading) {
                      _showImageSourceSheet();
                    }
                  },
                ),
                if (_image != null) ...[
                  const SizedBox(height: 20),
                  CustomButton(
                    text: _isLoading ? '' : 'Atualizar Imagem',
                    isLoading: _isLoading,
                    onPressed: () {
                      if (!_isLoading) {
                        _uploadImage();
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
