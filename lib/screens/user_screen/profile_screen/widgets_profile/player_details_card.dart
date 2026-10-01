import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/Providers/UsuarioProvider.dart';
import 'package:winbin/models/users_model.dart';

class PlayerDetailsCard extends StatefulWidget {
  const PlayerDetailsCard({super.key});

  @override
  State<PlayerDetailsCard> createState() => _PlayerDetailsCardState();
}

class _PlayerDetailsCardState extends State<PlayerDetailsCard> {
  late TextEditingController _nombreController;
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  bool _obspass = true;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.usuarioActual;
      _nombreController.text = user?.nombre ?? '';
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }
  Future<void> _guardarCambios() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.usuarioActual;
    final usuarioProvider = context.read<UsuarioProvider>();
    if (user == null) return;

    bool cambiosRealizados = false;

    if (_nombreController.text.isNotEmpty &&
        _nombreController.text != user.nombre) {
      final usuarioEditado = Usuario(
        documento: user.documento,
        nombre: _nombreController.text.trim(),
        activo: user.activo,
        avatarUrl: user.avatarUrl,
        rol: user.rol,
        puntos: user.puntos,
      );
      final exitoNombre = await usuarioProvider.actualizarUsuario(
        usuarioEditado,
      );
      if (exitoNombre) {
        cambiosRealizados = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nombre actualizado exitosamente', style: TextStyle(color: Colors.black)),
              backgroundColor: Color(0xFF00FF66),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    bool itentaCambiarPass =
        _oldPassController.text.isNotEmpty ||
        _newPassController.text.isNotEmpty;

    if (itentaCambiarPass) {
      if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debe ingresar la contraseña actual y la contraseña nueva', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (_newPassController.text.length < 6) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La nueva contraseña debe tener mínimo 6 caracteres', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final exitoPass = await authProvider.cambiarPassword(
        _oldPassController.text,
        _newPassController.text,
      );
      
      if (mounted) {
        if (exitoPass) {
          cambiosRealizados = true;
          _oldPassController.clear();
          _newPassController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada exitosamente', style: TextStyle(color: Colors.black)),
              backgroundColor: Color(0xFF00FF66),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar la contraseña', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red, // Rojo para errores
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    if (!cambiosRealizados && mounted && !itentaCambiarPass) {
      if (_nombreController.text == user.nombre) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay cambios para guardar'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isLoading = authProvider.isUpdatingProfile;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETALLES ',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nombre',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildInputField(controller: _nombreController),
          const SizedBox(height: 12),
          const Text(
            'Password Actual',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildInputField(
            controller: _oldPassController,
            isObscure: _obspass,
            hint: '***',
            showEyeIcon: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'Password Nueva',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildInputField(
            controller: _newPassController,
            isObscure: _obspass,
            hint: '***',
            showEyeIcon: true,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: isLoading ? null : _guardarCambios,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5FFCC),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  isLoading ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Courier',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    bool isObscure = false,
    String? hint = "",
    bool showEyeIcon = false,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Courier',
          fontSize: 13,
        ),
        cursorColor: const Color(0xFF00FF66),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          border: InputBorder.none,
          isDense: true,
          suffixIcon: showEyeIcon
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obspass = !_obspass;
                    });
                  },
                  child: Icon(
                    _obspass ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF00FF66),
                    size: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
