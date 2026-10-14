import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/screens/admin_screen/main_layout.dart';
import 'widgets_screen/custom_button.dart';
import 'widgets_screen/custom_text.dart';
import 'widgets_screen/login_footer.dart';
import 'widgets_screen/login_header.dart';
import 'package:go_router/go_router.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = context.read<AuthProvider>();

      final bool exito = await authProvider
          .iniciarSesion(
            _userController.text.trim(),
            _passwordController.text.trim(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado');
            },
          );

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bienvenido, ${_userController.text}',
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF00FF66),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/ranking');
      } else {
        _mostrarError('Credenciales incorrectas');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error de conexión: Verifica el estado del servidor');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HeaderTitle(),
                  const SizedBox(height: 25),

                  CustomTextField(
                    label: 'USUARIO',
                    hintText: 'Ingresa tu Documento',
                    controller: _userController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu documento';
                      }
                      if (value.trim().length < 4) {
                        return 'El documento debe tener al menos 4 digitos';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'Ingresa solo números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  CustomTextField(
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (value.trim().length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : CustomButton(
                          text: 'RECICLA',
                          icon: Icons.recycling,
                          backgroundColor: const Color(0xFF66BB6A),
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          onPressed: _onLogin,
                        ),
                  const SizedBox(height: 15),

                  CustomButton(
                    text: 'CREAR CUENTA',
                    icon: Icons.person_add_outlined,
                    backgroundColor: const Color(0xFFFF9999),
                    textColor: const Color(0xFF800000),
                    iconColor: const Color(0xFF800000),
                    onPressed: () {
                      context.go('/register');
                    },
                  ),
                  const SizedBox(height: 25),

                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 10),

                  const FooterText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
