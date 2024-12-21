import 'package:campus_sync/src/services/api_service.dart';

class ListagemController {
  final ApiService _listagemService = ApiService();

  Future<List<dynamic>> listar(String endpoint) async {
    try {
      return await _listagemService.listarDados(endpoint);
    } catch (e) {
      rethrow;
    }
  }
}
