enum PeriodoCurso { matutino, vespertino, noturno, integral }

extension PeriodoCursoExtension on PeriodoCurso {
  String get name {
    return toString().split('.').last;
  }

  static PeriodoCurso fromString(String periodo) {
    return PeriodoCurso.values.firstWhere((e) => e.name == periodo);
  }
}
