import 'package:flutter/foundation.dart';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/models/ranking_model.dart';
import 'package:winbin/models/perido_model.dart';

class HistorialRanking {
  final int id_historial;
  final int puesto;
  final String tipoPremio;
  final int puntosLogrados;
  final DateTime fecha;
  final int documento;
  final dynamic id_curso;
  final dynamic id_periodo;

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
      id_historial: json['id_historial'] ?? 0,
      puesto: json['puesto'] ?? 0,
      tipoPremio: json['tipoPremio'] ?? '',
      puntosLogrados: json['puntosLogrados'] ?? 0,
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now() : DateTime.now(),
      documento: json['documento'] ?? 0,
      id_curso: json['id_curso'] ?? 0,
      id_periodo: json['id_periodo'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_historial': id_historial,
      'puesto': puesto,
      'tipoPremio': tipoPremio,
      'puntosLogrados': puntosLogrados,
      'fecha': fecha.toIso8601String().split('T').first,
      'documento': documento,
      'id_curso': id_curso,
      'id_periodo': id_periodo,
    };
  }

  HistorialRanking copyWith({
    int? puesto,
    String? tipoPremio,
    int? puntosLogrados,
    DateTime? fecha,
    int? documento,
    dynamic id_curso,
    dynamic id_periodo,
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