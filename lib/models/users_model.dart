import 'auth_model.dart';

class Usuario {
  final bool activo;
  final String avatarUrl;
  final Curso? curso;
  final String documento;
  final String nombre;
  final int puntos;
  final String rol;

  Usuario({
    required this.activo,
    required this.avatarUrl,
    this.curso,
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
      documento: json['documento'] ?? '',
      nombre: json['nombre'] ?? '',
      puntos: json['puntos'] ?? 0,
      rol: json['rol'] ?? 'USER',
    );
  }

  
}
