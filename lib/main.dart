import 'package:flutter/material.dart';
import 'package:ts_management/screens/login_screen.dart';

void main() {
  runApp(const OxalisApp(subtitle: 'Student'));
}

class OxalisApp extends StatelessWidget {
  final String subtitle;

  const OxalisApp({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oxalis Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF1A0A2E),
      ),
      home: const LoginScreen(),
    );
  }
}
