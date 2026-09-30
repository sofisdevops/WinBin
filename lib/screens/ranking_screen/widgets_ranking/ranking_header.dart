import 'package:flutter/material.dart';

class RankingHeader extends StatelessWidget {
  const RankingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'RANKING',
          style: TextStyle(
            color: Color(0xFF00FF66),
            fontFamily: 'Courier',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '¿QUIEN ES EL MEJOR RECICLADOR?',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Courier',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]
    );
  }
}