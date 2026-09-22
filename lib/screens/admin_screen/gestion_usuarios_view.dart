import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                      'IDCurso',
                      'Puntos',
                      'Rol',
                      'AvatarUrl',
                    ],
                    data: provider.usuarios,
                    cellBuilders: [
                      (user) => Text(user.documento),
                      (user) => Text(user.nombre),
                      (user) => Text(user.curso.toString()),
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
                      // Abrir modal o navegar
                    },
                    onDelete: (user) {
                      // Eliminar usuario
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
