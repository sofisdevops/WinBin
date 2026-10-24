import 'package:flutter/foundation.dart';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/models/ranking_model.dart';

class HistorialRanking {
  final int id_historial;
  final int puesto;
  final String tipoPremio;
  final int puntosLogrados;
  final DateTime fecha;
  final UsuarioPerfil? documento;
  final Curso? id_curso;
  final Periodo? id_periodo;

  HistorialRanking({
    required this.id_historial,
    required this.puesto,
    required this.tipoPremio,
    required this.puntosLogrados,
    required this.fecha,
    required this.documento,
    required this.id_curso,
    required this.id_periodo,
  });

  factory HistorialRanking.fromJson(Map<String, dynamic> json) {
    return HistorialRanking(
      id_historial: json['id_historial'] is int
          ? json['id_historial']
          : int.tryParse(json['id_historial']?.toString() ?? '0') ?? 0,
      puesto: json['puesto'] is int
          ? json['puesto']
          : int.tryParse(json['puesto']?.toString() ?? '0') ?? 0,
      tipoPremio: json['tipoPremio']?.toString() ?? '',
      puntosLogrados: json['puntosLogrados'] is int
          ? json['puntosLogrados']
          : int.tryParse(json['puntosLogrados']?.toString() ?? '0') ?? 0,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      documento: json['documento'] is Map<String, dynamic>
          ? UsuarioPerfil.fromJson(json['documento'])
          : null,
      id_curso: json['id_curso'] is Map<String, dynamic>
          ? Curso.fromJson(json['id_curso'])
          : null,
      id_periodo: json['id_periodo'] is Map<String, dynamic>
          ? Periodo.fromJson(json['id_periodo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_historial': id_historial,
      'puesto': puesto,
      'tipoPremio': tipoPremio,
      'puntosLogrados': puntosLogrados,
      'fecha': fecha.toIso8601String().split('T').first,
      'documento': documento?.toJson(),
      'id_curso': id_curso?.toJson(),
      'id_periodo': id_periodo,
    };
  }

  HistorialRanking copyWith({
    int? puesto,
    String? tipoPremio,
    int? puntosLogrados,
    DateTime? fecha,
    UsuarioPerfil? documento,
    Curso? id_curso,
    Periodo? id_periodo,
  }) {
    return HistorialRanking(
      id_historial: id_historial,
      puesto: puesto ?? this.puesto,
      tipoPremio: tipoPremio ?? this.tipoPremio,
      puntosLogrados: puntosLogrados ?? this.puntosLogrados,
      fecha: fecha ?? this.fecha,
      documento: documento ?? this.documento,
      id_curso: id_curso ?? this.id_curso,
      id_periodo: id_periodo ?? this.id_periodo,
    );
  }
}
