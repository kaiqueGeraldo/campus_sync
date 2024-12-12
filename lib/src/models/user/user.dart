class User {
  final String cpf;
  final String nome;
  final String email;
  final String? urlImagem;
  final String? universidadeNome;
  final String? universidadeCNPJ;
  final String? universidadeContatoInfo;

  User({
    required this.cpf,
    required this.nome,
    required this.email,
    this.urlImagem,
    this.universidadeNome,
    this.universidadeCNPJ,
    this.universidadeContatoInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      cpf: json['cpf'],
      nome: json['nome'],
      email: json['email'],
      urlImagem: json['urlImagem'],
      universidadeNome: json['universidadeNome'],
      universidadeCNPJ: json['universidadeCNPJ'],
      universidadeContatoInfo: json['universidadeContatoInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'nome': nome,
      'email': email,
      'urlImagem': urlImagem,
      'universidadeNome': universidadeNome,
      'universidadeCNPJ': universidadeCNPJ,
      'universidadeContatoInfo': universidadeContatoInfo,
    };
  }
}
