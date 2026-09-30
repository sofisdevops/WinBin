import 'package:flutter/material.dart';

class PlayerDetailsCard extends StatelessWidget {
  const PlayerDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETALLES ',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nombre',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildField('Alex Recicla', showCursor: true),
          const SizedBox(height: 12),
          const Text(
            'Curso',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildField('6° A'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5FFCC),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Text(
                'GUARDAR CAMBIOS',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String text, {bool showCursor = false}) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 13,
            ),
          ),
          if (showCursor)
            Container(
              width: 8,
              height: 16,
              color: const Color(0xFF00FF66),
            ),
        ],
      ),
    );
  }
}