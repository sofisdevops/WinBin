import 'material_model.dart';
import 'package:winbin/models/puntajeCtaegoria_model.dart';
import 'package:winbin/models/session_model.dart';

class RegistroiaModel {
  final int? idIa;
  final int? confianza;
  final String? utlImagen;
  final DetalleSessionResponse? session;
  final PuntajeCategoria? categoria;
  final Material? material;

  RegistroiaModel({
    this.idIa,
    this.confianza,
    this.utlImagen,
    this.session,
    this.categoria,
    this.material,
  });

  factory RegistroiaModel.fromJson(Map<String, dynamic> json) {
    try {
      return RegistroiaModel(
        idIa: json['idIa'] ?? json['id_ia'],
        confianza: json['confianza'] != null ? json['confianza'] : null,
        utlImagen: json['utlImagen'] != null ? json['utlImagen'] : null,


        session: json['session'] != null
            ? DetalleSessionResponse.fromJson(
                json['session'] as Map<String, dynamic>,
              )
            : null,
        categoria: json['categoria'] != null
            ? PuntajeCategoria.fromJson(
                json['categoria'] as Map<String, dynamic>,
              )
            : null,
        material: json['material'] != null
            ? Material.fromJson(json['material'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, stackTrace) {
      print("❌ ERROR PARSEANDO RegistroiaModel en el JSON: $json");
      print("Detalle del error: $e");
      rethrow;
    }
  }
}
