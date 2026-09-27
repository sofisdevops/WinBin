import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/screens/login_screens/login_screen.dart';

import 'widgets_screen/custom_button.dart';
import 'widgets_screen/custom_text.dart';
import 'widgets_screen/login_footer.dart';
import 'widgets_screen/login_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String _loadingText = 'CREAR CUENTA';

  List<Curso>? _cursos = [];
  int? _cursoSeleccionadoId;

  bool _isLoadingCursos = true;
  Uint8List? _imageBytes;
  String? _imageExtension;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final cursosData = await authProvider.cargarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursosData!;

        if (_cursos != null && _cursos!.isNotEmpty) {
          _cursoSeleccionadoId = _cursos!.first.idCurso;
        }

        _isLoadingCursos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCursos = false;
      });
    }
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _documentoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageExtension = image.name.split('.').last;
      });
    }
  }

  Future<String?> _subirACloudinary(Uint8List bytes, String extension) async {
    final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";
    final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "";
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print(' ERROR: Faltan credenciales de Cloudinary en el .env');
      return null;
    }

    final Uri url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'avatar_winbin.$extension',
        ),
      );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = json.decode(responseData);
        return jsonMap['secure_url']; // Link público de la imagen
      }
    } catch (e) {
      print('Error en Cloudinary: $e');
    }
    return null;
  }

  Future<void> _onRegister() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _loadingText = 'REGISTRANDO...';
    });

    try {
      String avatarUrl = "";
      if (_imageBytes != null) {
        setState(() => _loadingText = 'SUBIENDO FOTO...');

        final String? urlSubida = await _subirACloudinary(
          _imageBytes!,
          _imageExtension ?? 'png',
        );

        if (urlSubida == null) {
          _mostrarError('Error al subir la imagen a Cloudinary');
          setState(() => _isLoading = false);
          return;
        }
        avatarUrl = urlSubida;
      }

      setState(() => _loadingText = 'REGISTRANDO...');

      final authProvider = context.read<AuthProvider>();
      final int cursoId = _cursoSeleccionadoId ?? 1;

      final bool exito = await authProvider.registrarUsuario(
        documento: _documentoController.text.trim(),
        nombre: _aliasController.text.trim(),
        cursoId: cursoId,
        contrasenna: _passwordController.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Registro Exitoso! Inicia sesión.',
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFF66BB6A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        _mostrarError('Error al registrar. Verifica los datos.');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error de conexión con el servidor.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingText = 'CREAR CUENTA';
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
        backgroundColor: const Color(0xFFFF9999),
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
                  const SizedBox(height: 5),
                  const Text(
                    'NUEVO USUARIO',
                    style: TextStyle(
                      color: Color(0xFF66BB6A),
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        'FOTO (OPCIONAL)',
                        style: TextStyle(
                          color: Color(0xFF66BB6A),
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _seleccionarImagen,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: _imageBytes == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'FOTO',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Courier',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Image.memory(_imageBytes!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),

                  CustomTextField(
                    label: 'NOMBRE ',
                    hintText: 'Ej. Alex',
                    controller: _aliasController,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Ingresa tu nombre'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'DOCUMENTO ',
                    hintText: 'Ingresa tu documento',
                    controller: _documentoController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Requerido';
                      if (!RegExp(r'^[0-9]+$').hasMatch(val))
                        return 'Solo números';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURSO ',
                        style: TextStyle(
                          color: Color(0xFF66BB6A),
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _isLoadingCursos
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF66BB6A),
                              ),
                            )
                          : DropdownButtonFormField<int>(
                              value: _cursoSeleccionadoId,
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              items: _cursos?.map((Curso curso) {
                                return DropdownMenuItem<int>(
                                  value: curso.idCurso,
                                  child: Text(curso.nombre),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _cursoSeleccionadoId = val);
                              },
                            ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'CONTRASEÑA',
                    hintText: '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    isObscured: _isPasswordObscured,
                    onToggleVisibility: () => setState(
                      () => _isPasswordObscured = !_isPasswordObscured,
                    ),
                    validator: (val) => val != null && val.length < 6
                        ? 'Mínimo 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'CONFIRMAR CONTRASEÑA',
                    hintText: '••••••••',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    isObscured: _isPasswordObscured,
                    onToggleVisibility: () => setState(
                      () => _isPasswordObscured = !_isPasswordObscured,
                    ),
                    validator: (val) => val != _passwordController.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                  const SizedBox(height: 25),

                  _isLoading
                      ? Column(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF66BB6A),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _loadingText,
                              style: const TextStyle(
                                color: Color(0xFF66BB6A),
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : CustomButton(
                          text: 'REGISTRARSE',
                          icon: Icons.person_add,
                          backgroundColor: const Color(0xFF66BB6A),
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          onPressed: _onRegister,
                        ),
                  const SizedBox(height: 15),

                  CustomButton(
                    text: 'VOLVER AL LOGIN',
                    icon: Icons.arrow_back,
                    backgroundColor: const Color(0xFFFF9999),
                    textColor: const Color(0xFF800000),
                    iconColor: const Color(0xFF800000),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    ),
                  ),
                  const SizedBox(height: 20),

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
