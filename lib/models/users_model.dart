import 'auth_model.dart';

class Usuario {
  final bool activo;
  final String avatarUrl;
  final Curso? curso;
  final String? contrasenna;
  final String documento;
  final String nombre;
  final int puntos;
  final String rol;

  Usuario({
    required this.activo,
    required this.avatarUrl,
    this.curso,
    this.contrasenna,
    required this.documento,
    required this.nombre,
    required this.puntos,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      activo: json['activo'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      curso: json['curso'] != null ? Curso.fromJson(json['curso']) : null,
      contrasenna: json['contrasenna'] ?? '',
      documento: json['documento'] ?? '',
      nombre: json['nombre'] ?? '',
      puntos: json['puntos'] ?? 0,
      rol: json['rol'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activo': activo,
      'avatarUrl': (avatarUrl != null && avatarUrl!.isNotEmpty)
          ? avatarUrl
          : null,
      'curso': {
        'id_curso': curso?.id_curso,
        'nombreCurso': curso?.nombre,
        'puntosTotales': curso?.puntosTotales,
      },
      'contrasenna': contrasenna,
      'documento': documento,
      'nombre': nombre,
      'puntos': puntos,
      'rol': rol,
    };
  }

  // Permite clonar el objeto cambiando solo algunos campos
  Usuario copyWith({
    bool? activo,
    String? avatarUrl,
    Curso? curso,
    String? contrasenna,
    int? puntos,
    String? rol,
    String? documento,
    String? nombre,
  }) {
    return Usuario(
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      curso: curso ?? this.curso,
      contrasenna:contrasenna ?? this.contrasenna ,
      documento: documento ?? this.documento,
      nombre: nombre ?? this.nombre,
      puntos: puntos ?? this.puntos,
      rol: rol ?? this.rol,
    );
  }
}
