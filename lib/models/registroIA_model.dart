import 'material_model.dart';
import 'package:winbin/models/puntajeCtaegoria_model.dart';
import 'package:winbin/models/session_model.dart';

class RegistroiaModel {
  final int idIa;
  final int? confianza;
  final String? utlImagen;
  final PuntajeCategoria? idCategoria;
  final Material? idMaterial;
  final DetalleSessionResponse? session;

  RegistroiaModel({
    required this.idIa,
    this.confianza,
    this.utlImagen,
    this.idCategoria,
    this.idMaterial,
    this.session,
  });

  factory RegistroiaModel.fromJson(Map<String, dynamic> json) {
       return RegistroiaModel(
        idIa: json['idIa'],
        confianza: json['confianza'],
        utlImagen: json['utlImagen'],
        idCategoria: PuntajeCategoria.fromJson(json['id_categoria'] ?? {}),
        idMaterial: Material.fromJson(json['id_material']),
        session: json['session'],
      );
    }
}
