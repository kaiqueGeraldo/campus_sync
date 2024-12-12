import 'package:campus_sync/src/models/enums/periodo_curso.dart';
import 'package:campus_sync/src/models/university/response/estudate_response.dart';

class TurmaResponse {
  final int id;
  final String nome;
  final PeriodoCurso periodo;
  final List<EstudanteResponse> estudantes;

  TurmaResponse({
    required this.id,
    required this.nome,
    required this.periodo,
    required this.estudantes,
  });

  factory TurmaResponse.fromJson(Map<String, dynamic> json) {
    return TurmaResponse(
      id: json['id'],
      nome: json['nome'],
      periodo: PeriodoCursoExtension.fromString(json['periodo']),
      estudantes: (json['estudantes'] as List)
          .map((e) => EstudanteResponse.fromJson(e))
          .toList(),
    );
  }
}
