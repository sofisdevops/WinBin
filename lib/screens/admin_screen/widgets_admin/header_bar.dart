import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/Providers/auditoria_provider.dart';
import 'package:winbin/utils/formatear_hora.dart';

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
      if (!mounted) return;
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
    final auditoriaProvider = context.watch<AuditoriaProvider>();
    final usuario = authProvider.usuarioActual;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
    return Column(
      children: [
        if (auditoriaProvider.hasWsError)
          Container(
            width: double.infinity,
            color: Colors.orange.shade900,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Conexión en tiempo real bloqueada. Desactiva tu AdBlocker o la protección de Brave para recibir notificaciones.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 18,
                  ),
                  tooltip: 'Reintentar conexión',
                  onPressed: () {
                    final token = authProvider.token;
                    if (token != null) {
                      context.read<AuditoriaProvider>().conectar(token);
                    }
                  },
                ),
              ],
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 16,
            vertical: 12,
          ),
          color: const Color(0xFFF7EFD8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<AuditoriaProvider>(
                      builder: (context, auditoriaProvider, child) {
                        return IconButton(
                          onPressed: () {
                            _showNotifications(context);
                          },
                          icon: Badge(
                            isLabelVisible:
                                auditoriaProvider.cantidadSinLeer > 0,
                            label: Text(
                              auditoriaProvider.cantidadSinLeer.toString(),
                            ),
                            child: const Icon(Icons.notifications_none),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: isMobile ? 0 : 10),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32),
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
                    if (!isMobile) ...[
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
                            usuario.nombre,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showNotifications(BuildContext context) {
  final bool isMobile = MediaQuery.of(context).size.width < 600;
  final Size size = MediaQuery.of(context).size;

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
              child: Text(
                'Marcar todas leidas',
                style: TextStyle(fontSize: isMobile ? 10 : 12),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: isMobile ? size.width * 0.9 : 500,
          height: size.height * 0.9,
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

                  //  PARSEO SEGURO DE FECHA (Evita FormatException)
                  final dynamic rawFecha = evento['fecha'];
                  DateTime? fechaSinformato;

                  if (rawFecha is String) {
                    fechaSinformato = DateTime.tryParse(rawFecha);
                  } else if (rawFecha is DateTime) {
                    fechaSinformato = rawFecha;
                  }

                  String fecha = fechaSinformato != null
                      ? formatearHoraColombiana(fechaSinformato)
                      : "Justo ahora";

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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 16,
                      ),
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
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usuario: ${evento['usuario'] ?? 'N/A'} | Tabla: ${evento['tabla'] ?? 'N/A'}',
                              style: TextStyle(fontSize: isMobile ? 12 : 14),
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
