import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/Providers/cursos_provider.dart';
import './widgets_admin/tablaGenerica.dart';

class GestionCursoView extends StatefulWidget {
  const GestionCursoView({super.key});

  @override
  State<GestionCursoView> createState() => _GestionCursoViewState();
}

class _GestionCursoViewState extends State<GestionCursoView> {
  final TextEditingController _nombreCursoCtrl = TextEditingController();
  final TextEditingController _puntosCursoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CursosProvider>().fetchCursos();
    });
  }

  @override
  void dispose() {
    _nombreCursoCtrl.dispose();
    _puntosCursoCtrl.dispose();
    super.dispose();
  }

  void _crearNuevoCurso() async {
    print('nombre: ${_nombreCursoCtrl.text}');
    print('puntos: ${_puntosCursoCtrl.text}');
    if (_nombreCursoCtrl.text.isEmpty || _puntosCursoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    final nuevoCurso = Curso(
      id_curso: 0,
      nombre: _nombreCursoCtrl.text,
      puntosTotales: int.parse(_puntosCursoCtrl.text),
    );

    final exito = await context.read<CursosProvider>().agregarCurso(nuevoCurso);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Curso programado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        _nombreCursoCtrl.clear();
        _puntosCursoCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al programar el periodo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarModalEdicion(BuildContext context, Curso curso) {
    final TextEditingController edNombreCtrl = TextEditingController(
      text: curso.nombre,
    );
    final TextEditingController edPuntosCtrl = TextEditingController(
      text: curso.puntosTotales.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text(
                'Editar Curso',
                style: TextStyle(color: Color(0xFF1B5E20)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: edNombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Curso',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: edPuntosCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Puntos Totales',
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B5E20),
                  ),
                  onPressed: () async {
                    final cursoActualizado = Curso(
                      id_curso: curso.id_curso, // Mantenemos el ID original
                      nombre: edNombreCtrl.text,
                      puntosTotales: int.parse(edPuntosCtrl.text),
                    );

                    final exito = await context
                        .read<CursosProvider>()
                        .actualizarCurso(cursoActualizado);
                    if (exito && mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Curso actualizado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Consumer<CursosProvider>(
      builder: (context, cursosProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Cursos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Administra los cursos .',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.library_add,
                          color: Color(0xFF1B5E20),
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nuevo Curso',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isMobile) ...[
                      _buildInputField(
                        label: 'Nombre del Curso',
                        hint: 'Nombre del Curso',
                        icon: Icons.text_fields,
                        controller: _nombreCursoCtrl,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Puntos Totales',
                        hint: 'Puntos Totales',
                        icon: Icons.numbers,
                        controller: _puntosCursoCtrl,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: 'Nombre del Curso',
                              hint: 'Nombre del Curso',
                              icon: Icons.text_fields,
                              controller: _nombreCursoCtrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              label: 'Puntos Totales',
                              hint: 'Puntos Totales',
                              icon: Icons.numbers,
                              controller: _puntosCursoCtrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1B5E20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: cursosProvider.isLoading
                            ? null
                            : _crearNuevoCurso,
                        child: cursosProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Crear Nuevo Curso',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de Cursos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (cursosProvider.isLoading &&
                        cursosProvider.cursos.isEmpty)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1B5E20),
                        ),
                      )
                    else if (cursosProvider.cursos.isEmpty)
                      const Center(
                        child: Text(
                          'No hay cursos programados',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      )
                    else
                      GenericTable<Curso>(
                        title: 'Cursos Registrados',
                        columns: const ['id', 'nombre_curso', 'puntos_totales'],
                        data: cursosProvider.cursos,
                        cellBuilders: [
                          (c) => Text(c.id_curso.toString()),
                          (c) => Text(c.nombre),
                          (c) => Text(c.puntosTotales.toString()),
                        ],
                        onEdit: (c){
                          _mostrarModalEdicion(context, c);
                        },
                        

                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildInputField({
  required String label,
  required String hint,
  IconData? icon,
  required TextEditingController controller,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Color(0xFF000000),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          suffixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: const Color(0xFFF1F8E9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
