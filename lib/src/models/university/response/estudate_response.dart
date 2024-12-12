import 'package:campus_sync/src/models/university/endereco.dart';
import 'package:campus_sync/src/models/university/pessoa.dart';

class EstudanteResponse extends Pessoa {
  final String numeroMatricula;
  final DateTime dataMatricula;
  final String telefonePai;
  final String telefoneMae;
  final String turmaNome;

  EstudanteResponse({
    required super.id,
    required super.nome,
    required super.cpf,
    required super.rg,
    required super.email,
    required super.telefone,
    required super.tituloEleitor,
    required super.estadoCivil,
    required super.nacionalidade,
    required super.corRacaEtnia,
    required super.escolaridade,
    required super.nomePai,
    required super.nomeMae,
    required super.dataNascimento,
    required super.endereco,
    required super.urlImagePerfil,
    required this.numeroMatricula,
    required this.dataMatricula,
    required this.telefonePai,
    required this.telefoneMae,
    required this.turmaNome,
  });

  factory EstudanteResponse.fromJson(Map<String, dynamic> json) {
    return EstudanteResponse(
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
      numeroMatricula: json['numeroMatricula'],
      dataMatricula: DateTime.parse(json['dataMatricula']),
      telefonePai: json['telefonePai'],
      telefoneMae: json['telefoneMae'],
      turmaNome: json['turmaNome'],
    );
  }
}
