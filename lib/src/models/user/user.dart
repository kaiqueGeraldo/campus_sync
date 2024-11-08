class User {
  final String cpf;
  final String nome;
  final String email;
  final String celular;

  User({
    required this.cpf,
    required this.nome,
    required this.email,
    required this.celular,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      cpf: json['cpf'],
      nome: json['nome'],
      email: json['email'],
      celular: json['celular'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'nome': nome,
      'email': email,
      'celular': celular,
    };
  }
}
