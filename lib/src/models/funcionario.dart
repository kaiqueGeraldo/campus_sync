import 'package:campus_sync/src/models/pessoa.dart';

class Funcionario extends Pessoa {
  final String cargo;
  final double salario;

  Funcionario({
    required super.id,
    required super.nome,
    required super.email,
    required super.telefone,
    required super.enderecoId,
    required super.dataNascimento,
    required super.urlImagePerfil,
    required this.cargo,
    required this.salario,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      enderecoId: json['enderecoId'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      urlImagePerfil: json['urlImagePerfil'],
      cargo: json['cargo'],
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
      'cargo': cargo,
      'salario': salario,
    };
  }
}
