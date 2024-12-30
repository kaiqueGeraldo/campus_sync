import 'dart:convert';
import 'dart:typed_data';
import 'package:campus_sync/src/views/components/custom_show_dialog.dart';
import 'package:campus_sync/src/views/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api';

  Future<Map<String, dynamic>> fetchUserProfile(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token == null) {
      _showLogoutMessage(context, 'Sessão expirada. Faça login novamente.');
      return {};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/User/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        _showLogoutMessage(context, 'Sessão expirada. Faça login novamente.');
        return {};
      } else {
        throw Exception(
            'Erro ao obter o perfil: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Erro ao fazer requisição: $e');
      throw Exception('Erro ao fazer requisição: $e');
    }
  }

  Future<void> refreshProfile(BuildContext context,
      ValueNotifier<Map<String, dynamic>> userProfile) async {
    try {
      final profileData = await fetchUserProfile(context);

      if (profileData.isNotEmpty) {
        userProfile.value = profileData;
      }
    } catch (e) {
      _showErrorDialog(context, 'Erro ao atualizar perfil: $e');
    }
  }

  Future<Uint8List?> getSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString('userImagem');
    if (base64Image != null) {
      try {
        return base64Decode(base64Image);
      } catch (e) {
        print("Erro ao decodificar a imagem: $e");
        return null;
      }
    }
    return null;
  }

  void _showLogoutMessage(BuildContext context, String message) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userToken');

    CustomSnackbar.show(context, message);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/signin');
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    customShowDialog(
      context: context,
      title: 'Erro',
      content: message,
      confirmText: 'OK',
      onConfirm: () => Navigator.pop(context),
    );
  }

  Future<String?> recuperarCPF() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userCpf');
  }

  Future<String> recuperarToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken') ?? '';

    return userToken;
  }

  // Verificar se o CPF já existe
  Future<bool> checkCpfExists(String cpf) async {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    final response =
        await http.get(Uri.parse('$baseUrl/User/verify-cpf?cpf=$cpf'));

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Erro ao verificar o CPF: ${response.statusCode}');
    }
  }

// Verificar se o email já existe
  Future<bool> checkEmailExists(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/User/verify-email?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception(
          'Erro ao verificar existência do e-mail: ${response.reasonPhrase}');
    }
  }

  // Reiniciar senha do usuário
  Future<bool> resetPassword(String cpf, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cpf': cpf,
        'newPassword': newPassword,
      }),
    );
    return response.statusCode == 200;
  }

  Future<http.Response?> cadastrarDados(
    String endpoint,
    Map<String, dynamic> formData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    String? cpf = prefs.getString('userCpf');
    try {
      final url = '$baseUrl/$endpoint';
      print('URL final: $url');
      print('Dados enviados: ${json.encode(formData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      return response;
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      return null;
    }
  }

  // listar entidades
  Future<List<dynamic>> listarDados(String endpoint) async {
    final cpf = await recuperarCPF();

    final url = Uri.parse('$baseUrl/$endpoint?cpf=$cpf');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Nenhuma faculdade encontrada para o CPF informado.');
    }
  }

  Future<List<Map<String, dynamic>>> carregarItens(String endpoint) async {
    if (['Faculdade', 'Curso', 'Estudante', 'Colaborador'].contains(endpoint)) {
      final List<dynamic> dados = await listarDados(endpoint);

      return dados.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          throw Exception('O item não é um Map<String, dynamic>');
        }
      }).toList();
    }

    return [];
  }

  // buscarCursosPorFaculdade
  Future<List<dynamic>> buscarCursosPorFaculdade(int id) async {
    try {
      final url = Uri.parse(
          'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/Curso/faculdade/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar dados');
      }
    } catch (e) {
      throw Exception('Falha ao carregar dados: $e');
    }
  }

  // buscarTurmasPorCurso
  Future<Map<String, dynamic>> buscarTurmasPorCurso(int id) async {
    try {
      final url = Uri.parse(
          'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/Curso/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          List<dynamic> turmas = data['turmas'] ?? [];

          data['quantidadeTurmas'] = turmas.length;

          return data;
        } else {
          throw Exception('Estrutura de dados inesperada');
        }
      } else {
        throw Exception('Falha ao carregar dados');
      }
    } catch (e) {
      throw Exception('Falha ao carregar dados: $e');
    }
  }

  // buscarDisciplinasPorCurso
  Future<List<dynamic>> buscarDisciplinasPorCurso(int id) async {
    try {
      final url = Uri.parse(
          'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/Curso/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('disciplinas')) {
          final disciplinas = data['disciplinas'];

          if (disciplinas is List) {
            return disciplinas;
          } else {
            throw Exception('Estrutura de dados de disciplinas inesperada');
          }
        } else {
          throw Exception('Campo "disciplinas" não encontrado');
        }
      } else {
        throw Exception('Falha ao carregar dados');
      }
    } catch (e) {
      throw Exception('Falha ao carregar dados: $e');
    }
  }

  Future<Map<String, dynamic>> listarDadosConfiguracoes(
      String endpoint, String id) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) ?? Map<String, dynamic>;
      } catch (e) {
        throw Exception(Text(
          'Erro ao decodificar resposta: $e',
          textAlign: TextAlign.center,
        ));
      }
    } else {
      throw Exception(Text(
        'Erro ao carregar dados: ${response.statusCode}',
        textAlign: TextAlign.center,
      ));
    }
  }

  Future<void> excluirDadosConfiguracoes(String endpoint, String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Erro ao excluir item: ${response.statusCode}');
    }
  }

  Future<int> fetchItemCount(String endpoint) async {
    final cpf = await recuperarCPF();

    final url = Uri.parse('$baseUrl/$endpoint?cpf=$cpf');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<List<dynamic>> listarFaculdades() async {
    final cpf = await recuperarCPF();

    final response = await http.get(
      Uri.parse('$baseUrl/Faculdade?cpf=$cpf'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Erro ao listar faculdades: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, int>> fetchAchievements(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/User/achievements'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'facultiesCreated': data['facultiesCreated'] ?? 0,
        'coursesCreated': data['coursesCreated'] ?? 0,
        'enrollmentsCompleted': data['enrollmentsCompleted'] ?? 0,
      };
    } else {
      throw Exception('Erro ao carregar conquistas');
    }
  }

  Future<Map<String, dynamic>?> fetchAddressByCep(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro') && data['erro'] == true) {
          return null;
        }
        return data;
      }
    } catch (e) {
      print('Erro ao buscar o endereço: $e');
    }
    return null;
  }
}
