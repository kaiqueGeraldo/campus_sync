import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl =
      'https://campussync-g6bngmbmd9e6abbb.canadacentral-01.azurewebsites.net/api';

  Future<http.Response> login(
    String email,
    String senha,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': senha,
      }),
    );
    return response;
  }

  Future<http.Response> register(
    String cpf,
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "cpf": cpf,
        "nome": username,
        "email": email,
        "celular": '',
        "password": password,
      }),
    );
    return response;
  }

  // Aqui você pode adicionar mais métodos, como recuperação de senha, etc.
}
