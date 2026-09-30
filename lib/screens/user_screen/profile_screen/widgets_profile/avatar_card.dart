import 'package:flutter/material.dart';

class AvatarCard extends StatelessWidget {
  const AvatarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 1.5),
      ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: const Color(0xFF00FF66),
          child: const Text(
            'AVATAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Courier',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFF0D140E),
            border: Border.all(color: const Color(0xFF00FF66), width: 1.5),
          ),
          child: const Icon(
            Icons.account_box,
            size: 85,
            color: Color(0xFF00FF66),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5FFCC),
              border: Border.all(color:Colors.black, width: 2),
            ),
            child: const Text(
              'CAMBIAR FOTO',
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
}