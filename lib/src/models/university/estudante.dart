import 'package:campus_sync/src/models/university/pessoa.dart';

class Estudante extends Pessoa {
  final String cpf;
  final String numEstudante;

  Estudante({
    required super.id,
    required super.nome,
    required super.email,
    required super.telefone,
    required super.enderecoId,
    required super.dataNascimento,
    required super.urlImagePerfil,
    required this.cpf,
    required this.numEstudante,
  });

  factory Estudante.fromJson(Map<String, dynamic> json) {
    return Estudante(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      enderecoId: json['enderecoId'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      urlImagePerfil: json['urlImagePerfil'],
      cpf: json['cpf'],
      numEstudante: json['numEstudante'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'enderecoId': enderecoId,
      'dataNascimento': dataNascimento.toIso8601String(),
      'urlImagePerfil': urlImagePerfil,
      'cpf': cpf,
      'numEstudante': numEstudante,
    };
  }
}
