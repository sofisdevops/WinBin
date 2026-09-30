import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/Providers/auditoria_provider.dart';

class HeaderBar extends StatefulWidget {
  const HeaderBar({super.key});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;
      if (token != null) {
        context.read<AuditoriaProvider>().cargarHistorial(token);
        context.read<AuditoriaProvider>().conectar(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final usuario = authProvider.usuarioActual;

    if (usuario == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: const Color(0xFFEEF7E8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      );
    }

    final bool tieneAvatar = usuario.avatarUrl.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF7EFD8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search, size: 20),
                fillColor: const Color(0xFFF5DB90),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<AuditoriaProvider>(
                  builder: (context, AuditoriaProvider, child) {
                    return IconButton(
                      onPressed: () {
                        _showNotifications(context);
                      },
                      icon: Badge(
                        isLabelVisible: AuditoriaProvider.cantidadSinLeer > 0,
                        label: Text(
                          AuditoriaProvider.cantidadSinLeer.toString(),
                        ),
                        child: const Icon(Icons.notifications_none),
                      ),
                    );
                  },
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFF2E7D32),
                  backgroundImage: tieneAvatar
                      ? NetworkImage(usuario.avatarUrl)
                      : null,
                  child: !tieneAvatar
                      ? Text(
                          usuario.nombre.isNotEmpty
                              ? usuario.nombre[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.rol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      usuario!.nombre,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showNotifications(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Notificaciones'),
            TextButton(
              onPressed: () {
                context.read<AuditoriaProvider>().marcarTodasComoLeidas();
              },
              child: const Text(
                'Marcar todas leidas',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 500,
          child: Consumer<AuditoriaProvider>(
            builder: (context, provider, child) {
              if (provider.eventos.isEmpty) {
                return const Center(
                  child: Text('No tienes notificaciones nuevas'),
                );
              }
              return ListView.builder(
                itemCount: provider.eventos.length,
                itemBuilder: (context, index) {
                  final evento = provider.eventos[index];
                  final bool estaLeida = evento['leido'] ?? true;
                  final String accion = evento['accion'] ?? "";

                  final String fecha = evento['fecha'] ?? "Justo ahora";

                  Color colorAccion = Colors.grey;
                  IconData iconoAccion = Icons.info;
                  if (accion == 'INSERT') {
                    colorAccion = Colors.green;
                    iconoAccion = Icons.add;
                  }
                  if (accion == 'UPDATE') {
                    colorAccion = Colors.orange;
                    iconoAccion = Icons.edit;
                  }
                  if (accion == 'DELETE') {
                    colorAccion = Colors.red;
                    iconoAccion = Icons.delete;
                  }

                  return Card(
                    color: estaLeida
                        ? Colors.white
                        : Colors.blue.withOpacity(0.1),
                    elevation: estaLeida ? 1 : 0,
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 12,
                        color: estaLeida ? Colors.transparent : Colors.blue,
                      ),
                      title: Text(
                        evento['mensaje'] ?? '',
                        style: TextStyle(
                          fontWeight: estaLeida
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${evento['usuario']} - Tabla: ${evento['tabla']}',
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fecha,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorAccion,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(iconoAccion, color: Colors.white),
                      ),
                      onTap: () {
                        // Al hacer clic sobre la notificación, la marcamos como leída
                        provider.marcarComoLeido(index);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
