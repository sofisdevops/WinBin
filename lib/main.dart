import 'package:flutter/material.dart';
import 'screens/victory_sceen/victory_screen.dart';

void main() {
  runApp(const MiAppWeb());
}

class MiAppWeb extends StatelessWidget {
  const MiAppWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WIN BIN :D',
      theme: ThemeData(
        fontFamily: 'Courier', 
      ),
      home: const VictoryScreen(),
    );
  }
}
