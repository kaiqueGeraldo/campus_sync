class Matricula {
  final int id;
  final int estudanteId;
  final int cursoId;
  final String periodo;
  final DateTime dataMatricula;

  Matricula({
    required this.id,
    required this.estudanteId,
    required this.cursoId,
    required this.periodo,
    required this.dataMatricula,
  });

  factory Matricula.fromJson(Map<String, dynamic> json) {
    return Matricula(
      id: json['id'],
      estudanteId: json['estudanteId'],
      cursoId: json['cursoId'],
      periodo: json['periodo'],
      dataMatricula: DateTime.parse(json['dataMatricula']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudanteId': estudanteId,
      'cursoId': cursoId,
      'periodo': periodo,
      'dataMatricula': dataMatricula.toIso8601String(),
    };
  }
}
