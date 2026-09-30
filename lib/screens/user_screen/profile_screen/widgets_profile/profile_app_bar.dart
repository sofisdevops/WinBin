import 'package:flutter/material.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.recycling, color: Color(0xFF00FF66), size: 22),
              SizedBox(width: 8),
              Text(
                'WINBIN',
                style: TextStyle(
                  color: Color(0xFF00FF66),
                  fontFamily: 'Courier',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border.all(color: const Color(0xFF2B2B2B)),
            ),
            child: const Row(
              children: [
                Icon(Icons.star_border, color: Color(0xFF00FF66), size: 14),
                SizedBox(width: 4),
                Text(
                  '0 PTS',
                  style: TextStyle(
                    color: Color(0xFF00FF66),
                    fontFamily: 'Courier',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}