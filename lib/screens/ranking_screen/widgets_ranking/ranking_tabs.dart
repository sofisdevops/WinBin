import 'package:flutter/material.dart';

class RankingTabs extends StatelessWidget {
  final bool showPersonas;
  final ValueChanged<bool> onSelectTab;

  const RankingTabs({
    super.key,
    required this.showPersonas,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectTab(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: showPersonas ? const Color(0xFFE5FFCC) : Colors.transparent,
                  border: showPersonas ? Border.all(color: Colors.black, width: 2) : null,
                ),
                child: Text(
                  'PERSONAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: showPersonas ? Colors.black : Colors.white,
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectTab(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !showPersonas ? const Color(0xFFE5FFCC) : Colors.transparent,
                  border: !showPersonas ? Border.all(color: Colors.black, width: 2) : null,
                ),
                child: Text(
                  'CURSOS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !showPersonas ? Colors.black : Colors.white,
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}