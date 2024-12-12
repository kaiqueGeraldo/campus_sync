import 'package:campus_sync/src/models/university/endereco.dart';
import 'package:campus_sync/src/models/university/pessoa.dart';

class ColaboradorResponse extends Pessoa {
  final String cargo;
  final String numeroRegistro;
  final DateTime dataAdmissao;
  final int? cursoId;
  final String? cursoNome;

  ColaboradorResponse({
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
    required this.cargo,
    required this.numeroRegistro,
    required this.dataAdmissao,
    this.cursoId,
    this.cursoNome,
  });

  factory ColaboradorResponse.fromJson(Map<String, dynamic> json) {
    return ColaboradorResponse(
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
      cargo: json['cargo'],
      numeroRegistro: json['numeroRegistro'],
      dataAdmissao: DateTime.parse(json['dataAdmissao']),
      cursoId: json['cursoId'],
      cursoNome: json['cursoNome'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'cargo': cargo,
      'numeroRegistro': numeroRegistro,
      'dataAdmissao': dataAdmissao.toIso8601String(),
      'cursoId': cursoId,
      'cursoNome': cursoNome,
    };
  }
}
