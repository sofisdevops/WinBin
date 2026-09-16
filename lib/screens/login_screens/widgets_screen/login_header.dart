import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WINBIN',
      style: TextStyle(
        color: Color(0xFF00FF66),
        fontSize: 36,
        fontFamily: 'Courier',
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}