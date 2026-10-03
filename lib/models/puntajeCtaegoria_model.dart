import 'material_model.dart';

class PuntajeCategoria {
  final int id_categoria;
  final String tamanno;
  int puntos;
  final Material? id_material;

  PuntajeCategoria({
    required this.id_categoria,
    required this.tamanno,
    required this.puntos,
    required this.id_material,
  });

  factory PuntajeCategoria.fromJson(Map<String, dynamic> json) {
    return PuntajeCategoria(
      id_categoria: json['id_categoria'] ?? 0,
      tamanno: json['tamanno'] ?? '',
      puntos: json['puntos'] ?? 0,
      id_material: json['id_material'] != null ? Material.fromJson(json['id_material']) : null,
    );
  }


  PuntajeCategoria copyWith({
    int? idCategoria,
    String? tamanno,
    int? puntos,
    Material? id_material,
  }) {
    return PuntajeCategoria(
      id_categoria: idCategoria ?? this.id_categoria,
      tamanno: tamanno ?? this.tamanno,
      puntos: puntos ?? this.puntos,
      id_material: id_material ?? this.id_material,
    );
  }

  // Método para convertir el objeto a JSON con la estructura requerida
  Map<String, dynamic> toJson() {
    return {
      'id_categoria': id_categoria,
      'tamanno': tamanno,
      'puntos': puntos,
      'id_material': id_material?.toJson(),
    };
  }
}
