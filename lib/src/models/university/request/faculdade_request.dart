import 'package:campus_sync/src/models/enums/tipo_facul.dart';
import 'package:campus_sync/src/models/university/endereco.dart';

class FaculdadeRequest {
  final String nome;
  final String cnpj;
  final String telefone;
  final String emailResponsavel;
  final Endereco endereco;
  final TipoFacul tipo;
  final String userCPF;

  FaculdadeRequest({
    required this.nome,
    required this.cnpj,
    required this.telefone,
    required this.emailResponsavel,
    required this.endereco,
    required this.tipo,
    required this.userCPF,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'emailResponsavel': emailResponsavel,
      'endereco': endereco.toJson(),
      'tipo': tipo.toString().split('.').last,
      'userCPF': userCPF,
    };
  }
}
