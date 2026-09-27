import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/Gestion_puntos_provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class GestionPuntosView extends StatelessWidget {
  const GestionPuntosView({super.key});

  @override
  Widget build(BuildContext context) {
    
    final gestionProvider = context.watch<GestionPuntosProvider>();
    final authProvider = context.read<AuthProvider>(); 

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
                        controller: gestionProvider.idController, // conectamos el controlador
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
                        controller: gestionProvider.nombreController, // conectamos el controlador
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
                      onPressed: () {
                        // al hacer clic, disparamos la busqueda pasando el token del usuario actual
                        gestionProvider.buscarEstudiantes(authProvider.token);
                      },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Resultados de Búsqueda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    // hacemos que el contador sea dinamico
                    Chip(
                      label: Text('${gestionProvider.estudiantesEncontrados.length} Estudiantes encontrados'), 
                      backgroundColor: const Color(0xFFC8E6C9)
                    ),
                  ],
                ),
                const Divider(),
                // si esta cargando mostramos una ruedita, sino mostramos la tabla
                gestionProvider.cargando 
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )
                  : DataTable(
                      columns: const [
                        DataColumn(label: Text('NOMBRE DEL ESTUDIANTE')),
                        DataColumn(label: Text('CURSO')),
                        DataColumn(label: Text('PUNTOS ACTUALES')),
                        DataColumn(label: Text('ACCIÓN')),
                      ],
                      // iteramos sobre la lista de la base de datos para crear las filas dinamicamente
                      rows: gestionProvider.estudiantesEncontrados.map((estudiante) {
                        return _buildDataRow(
                          context, 
                          estudiante.nombre, 
                          estudiante.curso?.nombre ?? 'Sin curso', 
                          estudiante.puntos.toString(),
                          estudiante.documento
                        );
                      }).toList(),
                    ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // Modifiqué ligeramente tu método para recibir el ID del estudiante (documento)
  DataRow _buildDataRow(BuildContext context, String name, String course, String points, String estudianteId) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(course)),
        DataCell(Text('$points pts', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold))),
        DataCell(
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            // Pasas el ID y el Nombre al diálogo de edición
            onPressed: () => _showEditDialog(context, name, estudianteId),
            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
            label: const Text('Editar Puntos', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ]
    );
  }

  void _showEditDialog(BuildContext context, String name, String estudianteId) {
    // ... tu código del diálogo se mantiene igual por ahora ...
    // Aquí a futuro también llamarás al Provider para guardar en la base de datos 
    // la suma o resta de puntos para el estudianteId.
  }
}