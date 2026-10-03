import 'package:flutter/material.dart';

class PodiumBanner extends StatelessWidget {
  final List<dynamic> topUsers;
  final bool isPersonas;

  const PodiumBanner({super.key, required this.topUsers, required this.isPersonas});

  @override
  Widget build(BuildContext context) {
    final user1 = topUsers.isNotEmpty ? topUsers[0] : null;
    final user2 = topUsers.length > 1 ? topUsers[1] : null;
    final user3 = topUsers.length > 2 ? topUsers[2] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            'RECYCLING LEADERBOARD',
            style: TextStyle(
              color: Color(0xFF00FF66),
              fontFamily: 'Courier',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'TOP RECYCLERS OF THE WEEK',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 24),
          
          // Fila del podio alineada por la parte inferior para que los nombres queden rectos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumStep('2', 75, const Color(0xFFC0C0C0), false, user2),
              const SizedBox(width: 8),
              _buildPodiumStep('1', 105, const Color(0xFFFFD700), true, user1),
              const SizedBox(width: 8),
              _buildPodiumStep('3', 55, const Color(0xFFCD7F32), false, user3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep(String position, double height, Color color, bool isFirst, dynamic user) {
    String nombre = '---';
    String puntos = '0';
    String? avatarUrl;

    if (user != null) {
      nombre = isPersonas 
          ? (user['nombre'] ?? '---') 
          : (user['nombreCurso'] ?? '---');

      puntos = isPersonas 
          ? '${user['puntos'] ?? 0}' 
          : '${user['puntosTotales'] ?? 0}';
      
      avatarUrl = isPersonas ? user['avatarUrl'] : null;

    }
    


    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Corona o estrella para el primer puesto
        if (isFirst) ...[
          const Icon(Icons.star, color: Colors.yellow, size: 24),
          const SizedBox(height: 4),
        ],

        // Avatar
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2B2B2B),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? const Icon(Icons.person, color: Colors.grey, size: 20)
              : null,
        ),
        const SizedBox(height: 8),

        // Caja del podio (Posición + Puntos dentro)
        Container(
          width: 85, // Más ancho para que quepan los puntos cómodamente
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            border: Border.all(color: color, width: isFirst ? 2 : 1.5),
            boxShadow: [
              if (isFirst)
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$position',
                style: TextStyle(
                  color: color,
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$puntos pts',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Courier',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Nombre abajo
        SizedBox(
          width: 85,
          child: Text(
            nombre,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}