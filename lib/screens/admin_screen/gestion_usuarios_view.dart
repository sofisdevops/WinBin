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
    return Consumer<UsuarioProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
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
                        backgroundColor: Color(0xFFC8E6C9),
                      ),
                    ],
                  ),
                  const Divider(),

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
                        width: 150, // Limita el ancho de la celda a 150px
                        child: Text(
                          user.avatarUrl,
                          overflow:
                              TextOverflow.ellipsis, // Muestra '...' al cortar
                          maxLines:
                              1, // Garantiza que no ocupe más de una línea
                        ),
                      ),
                    ],
                    onEdit: (user) {
                      // Abrir el modal
                      _showEditDialog(context, user);
                    },
                    onDelete: null,
                    desactive: (user) {
                      context.read<UsuarioProvider>().desactivar(
                        user.documento,
                      );
                    },
                    active: (user) {
                      context.read<UsuarioProvider>().activarUsuario(
                        user.documento,
                      );
                    },
                    cambiarRol:(user){
                    _dialogRol(context,user);
                    } ,
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

    final controllerPuntosUser = TextEditingController(
      text: usuario.puntos.toString(),
    );
    Curso? cursoSeleccionado = usuario.curso;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar usuario ${usuario.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controllerNameUser,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<Curso>?>(
                future: context.read<AuthProvider>().cargarCursos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error al cargar cursos: ${snapshot.error}');
                  }

                  final cursosDisponibles = snapshot.data ?? [];

                  Curso? cursoSeleccionado = cursosDisponibles.firstWhere(
                    (c) => c.id_curso == usuario.curso?.id_curso,
                    orElse: () => cursosDisponibles
                        .first, // Valor por defecto si no lo encuentra
                  );

                  return DropdownButtonFormField<Curso>(
                    initialValue: cursoSeleccionado,
                    decoration: const InputDecoration(labelText: 'Curso'),
                    items: cursosDisponibles.map((curso) {
                      return DropdownMenuItem<Curso>(
                        value: curso,
                        child: Text(
                          curso.nombre,
                        ), // Cambia 'nombre' si tu clase Curso usa otro atributo
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
                decoration: InputDecoration(labelText: 'Puntos'),
              ),
              const SizedBox(height: 10),
              
            ],
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
                  puntos:
                      int.tryParse(controllerPuntosUser.text) ?? usuario.puntos,
                );

                // Llamar al provider
                final exito = await context
                    .read<UsuarioProvider>()
                    .actualizarUsuario(usuarioActualizado);

                if (exito && context.mounted) {
                  Navigator.pop(context); // Cerrar diálogo
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
                    orElse: () => list
                        .first, // Valor por defecto si no lo encuentra
                  );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Rol de usuario ${usuario.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                initialValue: dropdownValue,
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
                // Llamar al provider
                final exito = await context
                    .read<UsuarioProvider>()
                    .cambiarRol(usuario.documento, dropdownValue);

                if (exito && context.mounted) {
                  Navigator.pop(context); // Cerrar diálogo
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
