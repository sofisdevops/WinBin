import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
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
