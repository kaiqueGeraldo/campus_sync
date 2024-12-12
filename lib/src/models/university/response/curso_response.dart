import 'package:campus_sync/src/models/university/response/disciplina_response.dart';
import 'package:campus_sync/src/models/university/response/turma_response.dart';

class CursoResponse {
  final int id;
  final String nome;
  final double mensalidade;
  final int faculdadeId;
  final String faculdadeNome;
  final String? colaboradorNome;
  final List<TurmaResponse> turmas;
  final List<DisciplinaResponse> disciplinas;

  CursoResponse({
    required this.id,
    required this.nome,
    required this.mensalidade,
    required this.faculdadeId,
    required this.faculdadeNome,
    this.colaboradorNome,
    required this.turmas,
    required this.disciplinas,
  });

  factory CursoResponse.fromJson(Map<String, dynamic> json) {
    return CursoResponse(
      id: json['id'],
      nome: json['nome'],
      mensalidade: json['mensalidade'].toDouble(),
      faculdadeId: json['faculdadeId'],
      faculdadeNome: json['faculdadeNome'],
      colaboradorNome: json['colaboradorNome'],
      turmas: (json['turmas'] as List)
          .map((e) => TurmaResponse.fromJson(e))
          .toList(),
      disciplinas: (json['disciplinas'] as List)
          .map((e) => DisciplinaResponse.fromJson(e))
          .toList(),
    );
  }
}
