import 'package:winbin/models/auth_model.dart';

class AuditoriaPage {
  final int? totalPages;
  final int? totalElements;
  final int? size;
  final List<Auditoria>? content;
  final int? number;
  final int? numberOfElements;
  final bool? first;
  final bool? last;
  final bool? empty;

  AuditoriaPage({
    this.totalPages,
    this.totalElements,
    this.size,
    this.content,
    this.number,
    this.numberOfElements,
    this.first,
    this.last,
    this.empty,
  });

  factory AuditoriaPage.fromJson(Map<String, dynamic> json) {
    return AuditoriaPage(
      totalPages: json['totalPages'] as int?,
      totalElements: json['totalElements'] as int?,
      size: json['size'] as int?,
      content: json['content'] != null
          ? (json['content'] as List).map((i) => Auditoria.fromJson(i)).toList()
          : null,
      number: json['number'] as int?,
      numberOfElements: json['numberOfElements'] as int?,
      first: json['first'] as bool?,
      last: json['last'] as bool?,
      empty: json['empty'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPages': totalPages,
      'totalElements': totalElements,
      'size': size,
      'content': content?.map((e) => e.toJson()).toList(),
      'number': number,
      'numberOfElements': numberOfElements,
      'first': first,
      'last': last,
      'empty': empty,
    };
  }
}

class Auditoria {
  final int? idAuditoria;
  final String? accion;
  final String? tablaAfectada;
  final String? valorAnterior;
  final String? valorActual;
  final DateTime? fecha;
  final UsuarioPerfil? documento;

  Auditoria({
    this.idAuditoria,
    this.accion,
    this.tablaAfectada,
    this.valorAnterior,
    this.valorActual,
    this.fecha,
    this.documento,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) {
    return Auditoria(
      idAuditoria: json['idAuditoria'] as int?,
      accion: json['accion'] as String?,
      tablaAfectada: json['tablaAfectada'] as String?,
      valorAnterior: json['valorAnterior'] as String?,
      valorActual: json['valorActual'] as String?,
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
      documento: json['documento'] != null
          ? UsuarioPerfil.fromJson(json['documento'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAuditoria': idAuditoria,
      'accion': accion,
      'tablaAfectada': tablaAfectada,
      'valorAnterior': valorAnterior,
      'valorActual': valorActual,
      'fecha': fecha?.toIso8601String(),
      'documento': documento?.toJson(),
    };
  }
}