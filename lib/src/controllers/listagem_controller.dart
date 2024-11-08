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

  String getSubtitleText(
      Map<String, String> fieldMapping, Map<String, dynamic> item) {
    final subtitleField1 = fieldMapping['subtitle1'] ?? 'cpf';
    final subtitleField2 = fieldMapping['subtitle2'] ?? 'email';
    return '${item[subtitleField1]?.toString() ?? 'CPF não disponível'}, ${item[subtitleField2] ?? 'Email não disponível'}';
  }
}
