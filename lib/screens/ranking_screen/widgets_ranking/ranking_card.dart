import 'package:flutter/material.dart';

class RankingCard extends StatelessWidget {
  final int position;
  final String title;
  final String? subtitle;
  final int points;
  final Color borderColor;
  final Color positionColor;
  final IconData icon;
  final String? avatarUrl; 

  const RankingCard({
    super.key,
    required this.position,
    required this.title,
    this.subtitle,
    required this.points,
    this.borderColor = const Color(0xFF2B2B2B),
    this.positionColor = Colors.yellow,
    this.icon = Icons.account_box,
    this.avatarUrl, // <-- Lo recibimos en el constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position',
              style: TextStyle(
                color: positionColor,
                fontFamily: 'Courier',
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // CUADRO DEL AVATAR / ÍCONO
          Container(
            width: 36,
            height: 36,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: const Color(0xFF0D140E),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
                  )
                : _buildDefaultIcon(),
          ),
          
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Courier',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.recycling, color: Color(0xFF00FF66), size: 10),
                      const SizedBox(width: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Courier',
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: const TextStyle(
                  color: Color(0xFF00FF66),
                  fontFamily: 'Courier',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'PTS',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Courier',
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Extraje el ícono a un método pequeñito para reutilizarlo limpio
  Widget _buildDefaultIcon() {
    return Icon(
      icon,
      size: 24,
      color: const Color(0xFF00FF66),
    );
  }
}