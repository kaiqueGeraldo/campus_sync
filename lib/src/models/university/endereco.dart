class Endereco {
  final int id;
  final String rua;
  final String cidade;
  final String estado;
  final String cep;

  Endereco({
    required this.id,
    required this.rua,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      id: json['id'],
      rua: json['rua'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rua': rua,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
    };
  }
}
