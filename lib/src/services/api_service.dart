import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campus_sync/src/models/user.dart';

class ApiService {
  final String baseUrl =
      'https://campussyncapi-cvgwgqawd2etfqfa.canadacentral-01.azurewebsites.net/api';

  Future<User> fetchUserData(String cpf) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/$cpf'),
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

  Future<bool> checkCpfExists(String cpf) async {
    final response = await http.get(Uri.parse('$baseUrl/Users/$cpf'));
    return response.statusCode == 200;
  }
}
