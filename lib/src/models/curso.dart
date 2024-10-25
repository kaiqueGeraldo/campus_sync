class Curso {
  final int id;
  final String descricao;
  final double mensalidade;
  final int faculdadeId;

  Curso({
    required this.id,
    required this.descricao,
    required this.mensalidade,
    required this.faculdadeId,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'],
      descricao: json['descricao'],
      mensalidade: json['mensalidade'].toDouble(),
      faculdadeId: json['faculdadeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'mensalidade': mensalidade,
      'faculdadeId': faculdadeId,
    };
  }
}
