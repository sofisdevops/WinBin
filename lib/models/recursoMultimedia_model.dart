class Recursomultimedia {
  final int id_recurso;
  final String tipoRecurso;
  final String categoria;
  final String? contenido;
  final String urlArchivo;
  final String estado;
  final List<String> material;

  Recursomultimedia({
    required this.id_recurso,
    required this.tipoRecurso,
    required this.categoria,
    required this.contenido,
    required this.urlArchivo,
    required this.estado,
    required this.material,
  });

  factory Recursomultimedia.fromJson(Map<String, dynamic> json) {
    return Recursomultimedia(
      id_recurso: json['id_recurso'] ?? 0,
      tipoRecurso: json['tipoRecurso'] ?? '',
      categoria: json['categoria'] ?? '',
      contenido: json['contenido'] ?? '',
      urlArchivo: json['urlArchivo'] ?? '',
      estado: json['estado'] ?? '',
      material: json['material'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_recurso': id_recurso,
      'tipoRecurso': tipoRecurso,
      'categoria': categoria,
      'contenido': contenido,
      'urlArchivo': urlArchivo,
      'estado': estado,
      'material': material,
    };
  }
}
