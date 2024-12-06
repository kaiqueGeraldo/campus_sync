import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campus_sync/src/models/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl =
      'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api';

  // Buscar dados do usuário pelo CPF
  Future<User> fetchUserData(String cpf) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Users/$cpf'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        return User.fromJson(jsonDecode(response.body));
      } catch (e) {
        throw Exception('Erro ao decodificar os dados do usuário: $e');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Usuário não encontrado');
    } else {
      throw Exception(
          'Erro ao carregar dados do usuário: ${response.reasonPhrase}');
    }
  }

  // Verificar se o CPF já existe
  Future<bool> checkCpfExists(String cpf) async {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    final response = await http.get(Uri.parse('$_baseUrl/Users/$cpf'));

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Erro ao verificar o CPF: ${response.statusCode}');
    }
  }

// Verificar se o email já existe (filtrando manualmente no cliente)
  Future<bool> checkEmailExists(String email) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Users'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);

      final user = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => null,
      );

      return user != null;
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
      String endpoint, Map<String, dynamic> formData,
      {String? faculdadeId}) async {
    try {
      // Define a URL dependendo se há um `faculdadeId`
      final url = faculdadeId != null
          ? '$_baseUrl/$endpoint/$faculdadeId'
          : '$_baseUrl/$endpoint';

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
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      throw Exception('Erro: Universidade não identificada.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint?universidadeId=$universidadeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<Map<String, dynamic>> listarDadosConfiguracoes(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    String? universidadeId = prefs.getString('universidadeId');

    if (universidadeId == null) {
      throw Exception('Erro: Universidade não identificada.');
    }

    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
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
    final response = await http.get(
      Uri.parse('$_baseUrl/Faculdades'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Erro ao listar faculdades: ${response.reasonPhrase}');
    }
  }
}
