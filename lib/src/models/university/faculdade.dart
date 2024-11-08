class Faculdade {
  final int id;
  final String nome;
  final int enderecoId;
  final String tipo;
  final int universidadeId;

  Faculdade({
    required this.id,
    required this.nome,
    required this.enderecoId,
    required this.tipo,
    required this.universidadeId,
  });

  factory Faculdade.fromJson(Map<String, dynamic> json) {
    return Faculdade(
      id: json['id'],
      nome: json['nome'],
      enderecoId: json['enderecoId'],
      tipo: json['tipo'],
      universidadeId: json['universidadeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'enderecoId': enderecoId,
      'tipo': tipo,
      'universidadeId': universidadeId,
    };
  }
}
