import 'dart:io';
import 'package:flutter/material.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class AvatarCard extends StatefulWidget {
  const AvatarCard({super.key});

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _cambiarFoto(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {

      final exito = await authProvider.actualizarAvatar(pickedFile);

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Avatar actualizado con éxito',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color(0xFF00FF66),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hubo un error al actualizar el avatar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.usuarioActual;
    final isLoading = authProvider.isUploadingAvatar;
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00FF66),
                    ),
                  )
                : (user?.avatarUrl != null)
                ? Image.network(user!.avatarUrl!, fit: BoxFit.cover)
                : const Icon(
                    Icons.account_box,
                    size: 85,
                    color: Color(0xFF00FF66),
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: isLoading ? null : () => _cambiarFoto(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : const Color(0xFFE5FFCC),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  isLoading ? 'SUBIENDO...' : 'CAMBIAR FOTO',
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
}
