import 'package:flutter/material.dart';

class PodiumBanner extends StatelessWidget {
  const PodiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'TOP RECYCLERS OF THE WEEK',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumBox('2', 50, Colors.grey, false),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 20),
                  const SizedBox(height: 2),
                  _buildPodiumBox('1', 70, const Color(0xFFFFD700), true),
                ],
              ),
              const SizedBox(width: 12),
              _buildPodiumBox('3', 40, const Color(0xFFCD7F32), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumBox(String position, double height, Color color, bool isFirst) {
    return Container(
      width: 45,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: color, width: isFirst ? 2 : 1.5),
      ),
      child: Center(
        child: Text(
          position,
          style: TextStyle(
            color: color,
            fontFamily: 'Courier',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}