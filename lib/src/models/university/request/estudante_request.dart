import 'package:campus_sync/src/models/university/endereco.dart';
import 'package:campus_sync/src/models/university/pessoa.dart';

class EstudanteRequest extends Pessoa {
  final String numeroMatricula;
  final DateTime dataMatricula;
  final String telefonePai;
  final String telefoneMae;
  final int turmaId;

  EstudanteRequest({
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
    required this.turmaId,
  });

  factory EstudanteRequest.fromJson(Map<String, dynamic> json) {
    return EstudanteRequest(
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
      turmaId: json['turmaId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'numeroMatricula': numeroMatricula,
      'dataMatricula': dataMatricula.toIso8601String(),
      'telefonePai': telefonePai,
      'telefoneMae': telefoneMae,
      'turmaId': turmaId,
    };
  }
}
