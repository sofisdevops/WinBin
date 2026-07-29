import 'package:flutter/material.dart';

class GestionPuntosView extends StatelessWidget {
  const GestionPuntosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Puntos', 
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF1B5E20)
                  )
                ),
                Text(
                  'Ajuste Manual de Puntos de Estudiante', 
                  style: TextStyle(
                    color: Colors.black54
                  )
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(20)),
              child: const Text(
                'Total de puntos: 1.2M pts', 
                style: TextStyle(
                  color: Color(0xFF1B5E20), 
                  fontWeight: FontWeight.bold
                )
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buscar Estudiante', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'ID DEL ESTUDIANTE',
                          hintText: 'Ej: WB-001',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'NOMBRE COMPLETO',
                          hintText: 'Nombre del alumno...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text('Buscar', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Resultados de Búsqueda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Chip(label: Text('3 Estudiantes encontrados'), backgroundColor: Color(0xFFC8E6C9)),
                  ],
                ),
                const Divider(),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('NOMBRE DEL ESTUDIANTE')),
                    DataColumn(label: Text('CURSO')),
                    DataColumn(label: Text('PUNTOS ACTUALES')),
                    DataColumn(label: Text('ACCIÓN')),
                  ],
                  rows: [
                    _buildDataRow(context, 'Roderick Correa', '901', '4,250'),
                    _buildDataRow(context, 'Nareth Ramirez', '1002', '3,890'),
                    _buildDataRow(context, 'Santiago Duarte', '1103', '12,100'),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, String name, String course, String points) {
    return DataRow(
      cells: [
        DataCell(Text(
          name, 
          style: const TextStyle(
            fontWeight: FontWeight.bold)
          )
        ),
        DataCell(Text(course)),
        DataCell(Text(
            '$points pts', 
            style: const TextStyle(
            color: Color(0xFF2E7D32), 
            fontWeight: FontWeight.bold)
          )
        ),
        DataCell(
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32)
            ),
            onPressed: () => _showEditDialog(context, name),
            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
            label: const Text('Editar Puntos', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ]
    );
  }

  void _showEditDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajustar puntos para $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Puntos a agregar/restar (+ / -)')),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Motivo del ajuste')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}