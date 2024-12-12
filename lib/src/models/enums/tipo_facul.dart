enum TipoFacul { publica, privada, militar }

extension TipoFaculExtension on TipoFacul {
  String get name {
    return toString().split('.').last;
  }

  static TipoFacul fromString(String tipo) {
    return TipoFacul.values.firstWhere((e) => e.name == tipo);
  }
}
