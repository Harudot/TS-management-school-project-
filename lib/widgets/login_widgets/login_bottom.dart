import 'package:flutter/material.dart';
import 'package:ts_management/screens/signup.dart';

class LoginBottom extends StatelessWidget {
  const LoginBottom({super.key});

  void _openSignUp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // sheet-ийг бүтэн дэлгэц хүртэл өргөх боломжтой
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88, // дэлгэцийн 88%-ийг эзэлнэ
        minChildSize: 0.5, // хамгийн бага 50%
        maxChildSize: 0.95, // хамгийн их 95%
        expand: false,
        builder: (_, scrollController) => const SignUpSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
        ),
        GestureDetector(
          onTap: () => _openSignUp(context),
          child: const Text(
            'Sign Up',
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
