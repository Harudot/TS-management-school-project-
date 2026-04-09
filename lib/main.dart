import 'package:flutter/material.dart';
import 'package:ts_management/screens/login.dart';

void main() {
  runApp(const OxalisApp());
}

class OxalisApp extends StatelessWidget {
  const OxalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oxalis Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF1A0A2E),
      ),
      home: LoginScreen(),
    );
  }
}
