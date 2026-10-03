import 'recursoMultimedia_model.dart';

class Material {
  final int id_material;
  final String nombreMaterial;
  final List<Recursomultimedia>? recursoMultimedia;

  Material({
    required this.id_material,
    required this.nombreMaterial,
    required this.recursoMultimedia,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id_material: json['id_material'] ?? 0,
      nombreMaterial: json['nombreMaterial'] ?? '',
      recursoMultimedia: json['recursoMultimedia'] != null
          ? (json['recursosMultimedia'] as List)
              .map((item) => Recursomultimedia.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_material': id_material,
      'nombreMaterial': nombreMaterial,
      'recursosMultimedia':
          recursoMultimedia!.map((r) => r.toJson()).toList(),
    };
  }

}