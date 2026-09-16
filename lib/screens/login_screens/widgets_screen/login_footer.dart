import 'package:flutter/material.dart';

class _FooterText extends StatelessWidget {
  const _FooterText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Empieza a ganar puntos y premios con tu reciclaje',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFFFFCC00),
        fontSize: 11,
        fontFamily: 'Courier',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}