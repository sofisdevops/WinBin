import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/gestion_puntos_provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/models/users_model.dart';
import 'package:winbin/screens/admin_screen/widgets_admin/tablaGenerica.dart';

class GestionPuntosView extends StatelessWidget {
  const GestionPuntosView({super.key});

  @override
  Widget build(BuildContext context) {
    final gestionProvider = context.watch<GestionPuntosProvider>();
    final authProvider = context.read<AuthProvider>();

    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 20,
      ), // Padding inferior para que no quede pegado al final
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildHeaderTitles(),
            const SizedBox(height: 16),
            _buildTotalRegistrosChip(gestionProvider),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderTitles(),
                _buildTotalRegistrosChip(gestionProvider),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // SECCIÓN DE BÚSQUEDA
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

                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          gestionProvider.idController,
                          'ID DEL ESTUDIANTE',
                          'Documento del alumno...',
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          gestionProvider.nombreController,
                          'NOMBRE COMPLETO',
                          'Nombre del alumno...',
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          gestionProvider.cursoController,
                          'CURSO',
                          'Curso del alumno...',
                        ),
                        const SizedBox(height: 15),
                        _buildSearchButton(gestionProvider, authProvider),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.idController,
                            'ID DEL ESTUDIANTE',
                            'Documento del alumno...',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.nombreController,
                            'NOMBRE COMPLETO',
                            'Nombre del alumno...',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.cursoController,
                            'CURSO',
                            'Curso del alumno...',
                          ),
                        ),
                        const SizedBox(width: 15),
                        _buildSearchButton(gestionProvider, authProvider),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN DE RESULTADOS
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alineación para móviles
                children: [
                  if (isMobile) ...[
                    const Text(
                      'Resultados de Búsqueda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildResultadosChip(gestionProvider),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Resultados de Búsqueda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildResultadosChip(gestionProvider),
                      ],
                    ),
                  ],

                  const Divider(height: 30),

                  // Si está cargando muestra el indicador, sino la tabla generica
                  gestionProvider.cargando
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF1B5E20),
                            ),
                          ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            (estudiante) =>
                                Text(estudiante.curso?.nombre ?? 'Sin curso'),
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
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Editar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return const Column(
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
    );
  }

  Widget _buildTotalRegistrosChip(GestionPuntosProvider provider) {
    return Chip(
      label: Text(
        'Total de Registros: ${provider.todosLosEstudiantes.length}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF1B5E20),
    );
  }

  Widget _buildResultadosChip(GestionPuntosProvider provider) {
    return Chip(
      label: Text(
        '${provider.estudiantesEncontrados.length} Estudiantes encontrados',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF1B5E20),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ), // Ajuste visual de altura
      ),
    );
  }

  Widget _buildSearchButton(
    GestionPuntosProvider gestionProvider,
    AuthProvider authProvider,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD06E4B),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        gestionProvider.buscarEstudiantes(authProvider.token);
      },
      icon: const Icon(Icons.search, color: Colors.white),
      label: const Text(
        'Buscar',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String name,
    String estudianteId,
  ) {}
}
