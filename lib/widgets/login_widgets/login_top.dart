import 'package:flutter/material.dart';

class LoginTop extends StatelessWidget {
  const LoginTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Logo ──
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2D1554),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B4FD4).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '✦',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Brand Name ──
        const Text(
          'Oxalis Hub',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 4),

        // ── Subtitle ──
        Text(
          'SMART CAMPUS NAVIGATION',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.0,
          ),
        ),
      ],
    );
  }
}
