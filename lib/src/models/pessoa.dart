class Pessoa {
  final int id;
  final String nome;
  final String email;
  final String telefone;
  final int enderecoId;
  final DateTime dataNascimento;
  final String urlImagePerfil;

  Pessoa({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.enderecoId,
    required this.dataNascimento,
    required this.urlImagePerfil,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      enderecoId: json['enderecoId'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      urlImagePerfil: json['urlImagePerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'enderecoId': enderecoId,
      'dataNascimento': dataNascimento.toIso8601String(),
      'urlImagePerfil': urlImagePerfil,
    };
  }
}
