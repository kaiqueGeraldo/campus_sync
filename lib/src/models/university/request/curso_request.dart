class CursoRequest {
  final String nome;
  final double mensalidade;
  final int faculdadeId;

  CursoRequest({
    required this.nome,
    required this.mensalidade,
    required this.faculdadeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'mensalidade': mensalidade,
      'faculdadeId': faculdadeId,
    };
  }
}
