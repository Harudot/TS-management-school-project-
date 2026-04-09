import 'package:flutter/material.dart';

class SignUpBottom extends StatelessWidget {
  const SignUpBottom({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
        ),
        GestureDetector(
          onTap: onLoginTap,
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Color(0xFFB47EFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
