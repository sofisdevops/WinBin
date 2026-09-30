import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/screens/admin_screen/widgets_admin/tablaGenerica.dart';
import '../../Providers/UsuarioProvider.dart';
import '../../models/users_model.dart';

class GestionUsuariosView extends StatefulWidget {
  const GestionUsuariosView({super.key});
  @override
  State<GestionUsuariosView> createState() => _gestionUsuario();
}

class _gestionUsuario extends State<GestionUsuariosView> {
  @override
  void initState() {
    super.initState();
    // Ejecutamos la petición una vez cargada la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsuarioProvider>(context, listen: false).fetchUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<UsuarioProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }

        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    Chip(
                      label: Text(
                        '${provider.usuarios.length} Estudiantes encontrados',
                      ),
                      backgroundColor: const Color(0xFFC8E6C9),
                    ),
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
                        Chip(
                          label: Text(
                            '${provider.usuarios.length} Estudiantes encontrados',
                          ),
                          backgroundColor: const Color(0xFFC8E6C9),
                        ),
                      ],
                    ),
                  ],
                  
                  const Divider(height: 30),

                  GenericTable<Usuario>(
                    title: 'Lista de Usuarios',
                    columns: const [
                      'Documento',
                      'Nombre',
                      'Activo',
                      'Curso',
                      'Puntos',
                      'Rol',
                      'AvatarUrl',
                    ],
                    data: provider.usuarios,
                    cellBuilders: [
                      (user) => Text(user.documento),
                      (user) => Text(user.nombre),
                      (user) => Text(user.activo.toString()),
                      (user) => Text(user.curso?.nombre ?? 'sin Curso'),
                      (user) => Text(user.puntos.toString()),
                      (user) => Text(user.rol),
                      (user) => SizedBox(
                        width: 150, 
                        child: Text(
                          user.avatarUrl,
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 1, 
                        ),
                      ),
                    ],
                    onEdit: (user) {
                      _showEditDialog(context, user);
                    },
                    onDelete: null,
                    desactive: (user) {
                      context.read<UsuarioProvider>().desactivar(user.documento);
                    },
                    active: (user) {
                      context.read<UsuarioProvider>().activarUsuario(user.documento);
                    },
                    cambiarRol: (user) {
                      _dialogRol(context, user);
                    },
                    isRowActive: (item) => item.activo,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Usuario usuario) {
    final controllerNameUser = TextEditingController(text: usuario.nombre);
    final controllerPuntosUser = TextEditingController(text: usuario.puntos.toString());
    
    Curso? cursoSeleccionado; 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar usuario ${usuario.nombre}'),
          content: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controllerNameUser,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<Curso>?>(
                  future: context.read<AuthProvider>().cargarCursos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text('Error al cargar cursos: ${snapshot.error}');
                    }

                    final cursosDisponibles = snapshot.data ?? [];

                    
                    final cursoInicial = cursosDisponibles.firstWhere(
                      (c) => c.id_curso == usuario.curso?.id_curso,
                      orElse: () => cursosDisponibles.first, 
                    );

                    cursoSeleccionado ??= cursoInicial;

                    return DropdownButtonFormField<Curso>(
                      value: cursoInicial,
                      decoration: const InputDecoration(labelText: 'Curso'),
                      items: cursosDisponibles.map((curso) {
                        return DropdownMenuItem<Curso>(
                          value: curso,
                          child: Text(curso.nombre), 
                        );
                      }).toList(),
                      onChanged: (val) {
                        cursoSeleccionado = val;
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: controllerPuntosUser,
                  decoration: const InputDecoration(labelText: 'Puntos'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              onPressed: () async {
                final usuarioActualizado = usuario.copyWith(
                  nombre: controllerNameUser.text,
                  curso: cursoSeleccionado,
                  puntos: int.tryParse(controllerPuntosUser.text) ?? usuario.puntos,
                );

                // Llamar al provider
                final exito = await context
                    .read<UsuarioProvider>()
                    .actualizarUsuario(usuarioActualizado);

                if (exito && context.mounted) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario actualizado correctamente'),
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
  }

  void _dialogRol(BuildContext context, Usuario usuario) {
    const List<String> list = <String>['ESTUDIANTE', 'ADMIN'];

    String dropdownValue = list.firstWhere(
      (c) => c == usuario.rol,
      orElse: () => list.first,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Rol de usuario ${usuario.nombre}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 10,
                  style: const TextStyle(color: Color.fromARGB(255, 17, 82, 17)),
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    dropdownValue = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              onPressed: () async {
                final exito = await context
                    .read<UsuarioProvider>()
                    .cambiarRol(usuario.documento, dropdownValue);

                if (exito && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rol del Usuario actualizado correctamente'),
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
  }
}