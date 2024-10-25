class Universidade {
  final int id;
  final String nome;
  final String endereco;
  final String contatoInfo;

  Universidade({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.contatoInfo,
  });

  factory Universidade.fromJson(Map<String, dynamic> json) {
    return Universidade(
      id: json['id'],
      nome: json['nome'],
      endereco: json['endereco'],
      contatoInfo: json['contatoInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'contatoInfo': contatoInfo,
    };
  }
}
