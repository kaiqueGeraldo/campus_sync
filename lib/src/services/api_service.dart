import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campus_sync/src/models/user.dart';
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

  // cadastrar entidade
  Future<http.Response?> cadastrarDados(
      String endpoint, Map<String, dynamic> formData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );
      return response;
    } catch (e) {
      // ignore: avoid_print
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
}
