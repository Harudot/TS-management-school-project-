import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSignUp,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E0D3A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ──
          const Text(
            'Create account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Join your campus community today',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          // ── Full Name ──
          const _FieldLabel('FULL NAME'),
          const SizedBox(height: 6),
          _InputField(
            controller: nameController,
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 12),

          // ── Email ──
          const _FieldLabel('EMAIL'),
          const SizedBox(height: 6),
          _InputField(
            controller: emailController,
            hint: 'your.email@university.edu',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 12),

          // ── Password ──
          const _FieldLabel('PASSWORD'),
          const SizedBox(height: 6),
          _PasswordInputField(
            controller: passwordController,
            hint: '••••••••',
            obscure: obscurePassword,
            onToggle: onTogglePassword,
          ),

          const SizedBox(height: 12),

          // ── Confirm Password ──
          const _FieldLabel('CONFIRM PASSWORD'),
          const SizedBox(height: 6),
          _PasswordInputField(
            controller: confirmPasswordController,
            hint: '••••••••',
            obscure: obscureConfirm,
            onToggle: onToggleConfirm,
          ),

          const SizedBox(height: 18),

          // ── Sign Up Button ──
          _SignUpButton(onPressed: onSignUp),

          const SizedBox(height: 14),

          // ── OR Divider ──
          const _OrDivider(),

          const SizedBox(height: 14),

          // ── Google Button ──
          const _GoogleButton(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Field Label
// ─────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Generic Input Field
// ─────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1250).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Password Input Field
// ─────────────────────────────────────────────

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1250).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sign Up Button
// ─────────────────────────────────────────────

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B6BFF), Color(0xFF7340E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B4FD4).withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OR Divider
// ─────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Google Button
// ─────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const _GoogleLogo(),
        label: Text(
          'Continue with Google',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
          backgroundColor: const Color(0xFF2A1250).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Google Logo
// ─────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(20, 20), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    final segments = [
      (Colors.red, -15.0, 95.0),
      (Colors.amber, 80.0, 100.0),
      (Colors.green, 175.0, 100.0),
      (const Color(0xFF4285F4), 270.0, 105.0),
    ];

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    for (final seg in segments) {
      final paint = Paint()
        ..color = seg.$1 as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect.deflate(size.width * 0.11),
        (seg.$2 as double) * (3.14159 / 180),
        (seg.$3 as double) * (3.14159 / 180),
        false,
        paint,
      );
    }

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.78, cy), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
