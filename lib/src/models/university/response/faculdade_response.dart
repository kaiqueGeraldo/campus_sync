import 'package:campus_sync/src/models/enums/tipo_facul.dart';
import 'package:campus_sync/src/models/university/endereco.dart';
import 'package:campus_sync/src/models/university/response/curso_response.dart';

class FaculdadeResponse {
  final int id;
  final String nome;
  final String cnpj;
  final String telefone;
  final String emailResponsavel;
  final Endereco endereco;
  final TipoFacul tipo;
  final String universidadeNome;
  final List<CursoResponse> cursos;

  FaculdadeResponse({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.telefone,
    required this.emailResponsavel,
    required this.endereco,
    required this.tipo,
    required this.universidadeNome,
    required this.cursos,
  });

  factory FaculdadeResponse.fromJson(Map<String, dynamic> json) {
    return FaculdadeResponse(
      id: json['id'],
      nome: json['nome'],
      cnpj: json['cnpj'],
      telefone: json['telefone'],
      emailResponsavel: json['emailResponsavel'],
      endereco: Endereco.fromJson(json['endereco']),
      tipo: TipoFaculExtension.fromString(json['tipo']),
      universidadeNome: json['universidadeNome'],
      cursos: (json['cursos'] as List)
          .map((e) => CursoResponse.fromJson(e))
          .toList(),
    );
  }

  String get tipoString => tipo.name;
}
