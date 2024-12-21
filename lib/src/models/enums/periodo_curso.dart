enum PeriodoCurso { matutino, vespertino, noturno, integral }

extension PeriodoCursoExtension on PeriodoCurso {
  String get name {
    final name = toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  static PeriodoCurso fromString(String periodo) {
    return PeriodoCurso.values.firstWhere(
      (e) => e.name.toLowerCase() == periodo.toLowerCase(),
    );
  }
}
