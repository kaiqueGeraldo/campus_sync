import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl =
      'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api';

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api/User/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('Token: $token');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erro ao obter o perfil: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Tratar qualquer erro na requisição
      throw Exception('Erro ao fazer requisição: $e');
    }
  }

  Future<String?> recuperarCPF() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userCpf');
  }

  // Verificar se o CPF já existe
  Future<bool> checkCpfExists(String cpf) async {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    final response =
        await http.get(Uri.parse('$_baseUrl/User/verify-cpf?cpf=$cpf'));

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
      Uri.parse('$_baseUrl/User/verify-email?email=$email'),
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
      Uri.parse('$_baseUrl/Auth/reset-password'),
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
      final url = '$_baseUrl/$endpoint';
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
    if (endpoint == 'Faculdade') {
      endpoint += '?cpf=$cpf';
      print('cpf: $cpf');
    }

    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
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

  // listar entidades
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

  Future<Map<String, dynamic>> listarDadosConfiguracoes(
      String endpoint, String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      throw Exception('Erro: Universidade não identificada.');
    }

    final url = Uri.parse('$_baseUrl/$endpoint/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Erro ao decodificar resposta: $e');
      }
    } else {
      throw Exception('Erro ao carregar dados: ${response.statusCode}');
    }
  }

  Future<void> excluirDadosConfiguracoes(String endpoint, String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      throw Exception('Erro: Universidade não identificada.');
    }

    final response = await http.delete(Uri.parse('$_baseUrl/$endpoint/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Erro ao excluir item: ${response.statusCode}');
    }
  }

  Future<void> recriarDadosConfiguracoes(
      String endpoint, Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      throw Exception('Erro: Universidade não identificada.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    } else {
      throw Exception('Erro ao recriar item: ${response.statusCode}');
    }
  }

  Future<int> fetchItemCount(String endpoint) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/$endpoint"));
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
      Uri.parse('$_baseUrl/Faculdade?cpf=$cpf'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Erro ao listar faculdades: ${response.reasonPhrase}');
    }
  }
}
