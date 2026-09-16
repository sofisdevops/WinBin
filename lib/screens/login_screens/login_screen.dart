import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              border: Border.all(color: Colors.grey.shade400, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 10,
                  offset: Offset(4, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _HeaderTitle(),
                const SizedBox(height: 25),

                _CustomTextField(
                  label: 'USUARIO',
                  hintText: 'Ingresa tu ID',
                  controller: _userController,
                ),
                const SizedBox(height: 18),

                _CustomTextField(
                  label: 'CONTRASEÑA',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  isObscured: _isPasswordObscured,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 25),

                _CustomButton(
                  text: 'RECICLA',
                  icon: Icons.recycling,
                  backgroundColor: const Color(0xFF66BB6A),
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 15),

                _CustomButton(
                  text: 'CREAR CUENTA',
                  icon: Icons.person_add_outlined,
                  backgroundColor: const Color(0xFFFF9999),
                  textColor: const Color(0xFF800000),
                  iconColor: const Color(0xFF800000),
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 25),

                const Divider(color: Colors.grey, thickness: 1),
                const SizedBox(height: 10),
                
                const _FooterText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WINBIN',
      style: TextStyle(
        color: Color(0xFF00FF66),
        fontSize: 36,
        fontFamily: 'Courier',
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool isObscured;
  final VoidCallback? onToggleVisibility;

  const _CustomTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isObscured = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF66BB6A),
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          color: Colors.white,
          height: 48,
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            obscureText: isPassword && isObscured,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF00FF66),
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const _CustomButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  const _FooterText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Empieza a ganar puntos y premios con tu reciclaje',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFFFFCC00),
        fontSize: 11,
        fontFamily: 'Courier',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}