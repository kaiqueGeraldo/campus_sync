import 'dart:io';
import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isUploading = false;

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
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      CustomSnackbar.show(context, 'Imagem atualizada com sucesso!',
          backgroundColor: AppColors.successColor);
    } catch (e) {
      CustomSnackbar.show(context, 'Erro ao atualizar imagem: $e',
          backgroundColor: AppColors.successColor);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: const Text('Logo da Empresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: Image.file(
                    File(_image!.path),
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
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: const ButtonStyle(
                    elevation: WidgetStatePropertyAll(4),
                    backgroundColor:
                        WidgetStatePropertyAll(AppColors.buttonColor),
                    foregroundColor:
                        WidgetStatePropertyAll(AppColors.textColor),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  onPressed: _showImageSourceSheet,
                  child: const Text(
                    'Escolher Imagem',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              if (_image != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      elevation: WidgetStatePropertyAll(4),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.buttonColor),
                      foregroundColor:
                          WidgetStatePropertyAll(AppColors.textColor),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    onPressed: _isUploading ? null : _uploadImage,
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Atualizar Imagem',
                            style: TextStyle(fontSize: 15),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
