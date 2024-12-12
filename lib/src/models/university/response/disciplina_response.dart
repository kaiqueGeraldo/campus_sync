class DisciplinaResponse {
  final int id;
  final String nome;
  final String descricao;

  DisciplinaResponse({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  factory DisciplinaResponse.fromJson(Map<String, dynamic> json) {
    return DisciplinaResponse(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
    );
  }
}
