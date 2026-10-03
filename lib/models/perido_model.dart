class Periodo {
  String idPeriodo;
  String nombrePeriodo;
  String fechaInicio;
  String fechaFin;
  bool activo;

  Periodo({
    required this.idPeriodo,
    required this.nombrePeriodo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
  });

 
  factory Periodo.fromJson(Map<String, dynamic> json) {
    return Periodo(
      idPeriodo: json['id_periodo'] ?? '',
      nombrePeriodo: json['nombrePeriodo'] ?? '',
      fechaInicio: json['fechaInicio'] ?? '',
      fechaFin: json['fechaFin'] ?? '',
      activo: json['activo'] ?? false,
    );
  }

 
  Map<String, dynamic> toJson() {
    return {
      'id_periodo': idPeriodo,
      'nombrePeriodo': nombrePeriodo,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'activo': activo,
    };
  }

  Periodo copyWith({
    String? nombrePeriodo,
    String? fechaInicio,
    String? fechaFin,
    bool? activo,

  }) {
    return Periodo(
      idPeriodo: idPeriodo,
      nombrePeriodo: nombrePeriodo ?? this.nombrePeriodo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      activo: activo ?? this.activo,
    );
  }
}