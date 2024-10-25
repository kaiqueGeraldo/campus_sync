class FaculdadeProfessor {
  final int id;
  final int professorId;
  final int faculdadeId;

  FaculdadeProfessor({
    required this.id,
    required this.professorId,
    required this.faculdadeId,
  });

  factory FaculdadeProfessor.fromJson(Map<String, dynamic> json) {
    return FaculdadeProfessor(
      id: json['id'],
      professorId: json['professorId'],
      faculdadeId: json['faculdadeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professorId': professorId,
      'faculdadeId': faculdadeId,
    };
  }
}
