import 'auth_model.dart';

class DetalleSessionResponse {
  final String? idSesion;
  final UsuarioPerfil documento;
  final DateTime?fechaHora;
  final Categoria? categoria;
  final Periodo idPeriodo;

  DetalleSessionResponse({
    required this.documento,
    required this.idPeriodo,
    this.idSesion,
    this.fechaHora,
    this.categoria,

  });

  factory DetalleSessionResponse.fromJson(Map<String, dynamic> json) {
    return DetalleSessionResponse(
      idSesion: json['id_session'],
      documento: UsuarioPerfil.fromJson(json['documento'] ?? {}),
      idPeriodo: Periodo.fromJson(json['id_periodo'] ?? {}),
      fechaHora: json['fechaHora'] != null ? DateTime.parse(json['fechaHora']) : null,
      categoria: json['idCategoria'] != null ? Categoria.fromJson(json['idCategoria']) : null,
    );
  }
}

class Categoria {
  final int? idCategoria;
  final String? tamanno;
  final int? puntos;

  Categoria({this.idCategoria, this.tamanno, this.puntos});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['id_categoria'],
      tamanno: json['tamanno'],
      puntos: json['puntos'],
    );
  }
}

