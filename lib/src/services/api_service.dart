import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'https://campussyncapi-cvgwgqawd2etfqfa.canadacentral-01.azurewebsites.net/api';

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
