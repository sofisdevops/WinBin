import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/Gestion_puntos_provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/models/users_model.dart';
import 'package:winbin/screens/admin_screen/widgets_admin/tablaGenerica.dart';

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
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  'Ajuste Manual de Puntos de Estudiante',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),

            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        'Total de Registros: ${gestionProvider.todosLosEstudiantes.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                      backgroundColor: const Color(0xFF1B5E20),
                    ),
                  ],
                ),
            
          ],
        ),
        
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar Estudiante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gestionProvider.idController, // conectamos el controlador
                        decoration: InputDecoration(
                          labelText: 'ID DEL ESTUDIANTE',
                          hintText: 'Documento del alumno...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: gestionProvider.cursoController, // conectamos el controlador
                        decoration: InputDecoration(
                          labelText: 'CURSO',
                          hintText: 'Curso del alumno...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD06E4B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // al hacer clic, disparamos la busqueda pasando el token del usuario actual
                        gestionProvider.buscarEstudiantes(authProvider.token);
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'Buscar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
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
                    const Text(
                      'Resultados de Búsqueda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(
                        '${gestionProvider.estudiantesEncontrados.length} Estudiantes encontrados',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                      backgroundColor: const Color(0xFF1B5E20),
                    ),
                  ],
                ),
                const Divider(),

                // si carga muesstra la ruedita, sino la tabla
                gestionProvider.cargando
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                    : GenericTable<Usuario>(
                        title: 'Lista de Estudiantes',
                        rowsPerPage: 5,
                        columns: const [
                          'NOMBRE DEL ESTUDIANTE',
                          'CURSO',
                          'PUNTOS ACTUALES',
                          'ACCIÓN',
                        ],
                        data: gestionProvider.estudiantesEncontrados,
                        cellBuilders: [

                          (estudiante) => Text(
                                estudiante.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              
                          (estudiante) => Text(
                                estudiante.curso?.nombre ?? 'Sin curso',
                              ),

                          (estudiante) => Text(
                                '${estudiante.puntos} pts',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                          (estudiante) => ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B5E20),
                                ),
                                onPressed: () => _showEditDialog(
                                  context,
                                  estudiante.nombre,
                                  estudiante.documento,
                                ),
                                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                label: const Text(
                                  'Editar Puntos',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                        ],
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _showEditDialog(BuildContext context, String name, String estudianteId) {
    
  }
}
