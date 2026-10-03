class CursoModel {
  final int idCurso;
  final String nombreCurso;
  final int puntosTotales;

  CursoModel({
    required this.idCurso,
    required this.nombreCurso,
    required this.puntosTotales,
  });

  factory CursoModel.fromJson(Map<String, dynamic> json) {
    return CursoModel(
      idCurso: json['id_curso'] ?? 0,
      nombreCurso: json['nombreCurso'] ?? 'Sin curso',
      puntosTotales: json['puntosTotales'] ?? 0,
    );
  }
}

class RankingUserModel {
  final String documento;
  final String nombre;
  final String rol;
  final CursoModel? curso; 
  final String contrasenna;
  final int puntos;
  final bool activo;
  final String avatarUrl;

  RankingUserModel({
    required this.documento,
    required this.nombre,
    required this.rol,
    this.curso,
    required this.contrasenna,
    required this.puntos,
    required this.activo,
    required this.avatarUrl,
  });

  factory RankingUserModel.fromJson(Map<String, dynamic> json) {
    return RankingUserModel(
      documento: json['documento'] ?? '',
      nombre: json['nombre'] ?? 'Desconocido',
      rol: json['rol'] ?? 'ESTUDIANTE',
      curso: json['curso'] != null ? CursoModel.fromJson(json['curso']) : null,
      contrasenna: json['contrasenna'] ?? '',
      puntos: json['puntos'] ?? 0,
      activo: json['activo'] ?? true,
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}