import 'package:campus_sync/src/models/pessoa.dart';

class Professor extends Pessoa {
  final String formacoes;
  final double salario;

  Professor({
    required super.id,
    required super.nome,
    required super.email,
    required super.telefone,
    required super.enderecoId,
    required super.dataNascimento,
    required super.urlImagePerfil,
    required this.formacoes,
    required this.salario,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      enderecoId: json['enderecoId'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      urlImagePerfil: json['urlImagePerfil'],
      formacoes: json['formacoes'],
      salario: json['salario'].toDouble(),
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
      'formacoes': formacoes,
      'salario': salario,
    };
  }
}
