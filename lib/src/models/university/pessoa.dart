import 'package:campus_sync/src/models/university/endereco.dart';

class Pessoa {
  final int id;
  final String nome;
  final String cpf;
  final String rg;
  final String email;
  final String telefone;
  final String tituloEleitor;
  final String estadoCivil;
  final String nacionalidade;
  final String corRacaEtnia;
  final String escolaridade;
  final String nomePai;
  final String nomeMae;
  final DateTime dataNascimento;
  final Endereco endereco;
  final String urlImagePerfil;

  Pessoa({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.rg,
    required this.email,
    required this.telefone,
    required this.tituloEleitor,
    required this.estadoCivil,
    required this.nacionalidade,
    required this.corRacaEtnia,
    required this.escolaridade,
    required this.nomePai,
    required this.nomeMae,
    required this.dataNascimento,
    required this.endereco,
    required this.urlImagePerfil,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      id: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      rg: json['rg'],
      email: json['email'],
      telefone: json['telefone'],
      tituloEleitor: json['tituloEleitor'],
      estadoCivil: json['estadoCivil'],
      nacionalidade: json['nacionalidade'],
      corRacaEtnia: json['corRacaEtnia'],
      escolaridade: json['escolaridade'],
      nomePai: json['nomePai'],
      nomeMae: json['nomeMae'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      endereco: Endereco.fromJson(json['endereco']),
      urlImagePerfil: json['urlImagePerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'email': email,
      'telefone': telefone,
      'tituloEleitor': tituloEleitor,
      'estadoCivil': estadoCivil,
      'nacionalidade': nacionalidade,
      'corRacaEtnia': corRacaEtnia,
      'escolaridade': escolaridade,
      'nomePai': nomePai,
      'nomeMae': nomeMae,
      'dataNascimento': dataNascimento.toIso8601String(),
      'endereco': endereco.toJson(),
      'urlImagePerfil': urlImagePerfil,
    };
  }
}