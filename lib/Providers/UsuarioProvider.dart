import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../services/TableServices.dart';
import '../models/users_model.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:flutter/foundation.dart';

class UsuarioProvider extends ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _token;

  // Método para recibir el token actualizado del AuthProvider
  void updateToken(String? token) {
    _token = token;
  }

  // Cargar datos de la BD externa
  Future<void> fetchUsuarios() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _usuarios = await _apiService.traerDatos<Usuario>(
        endpoint: 'usuarios/todos',
        fromjson: (json) => Usuario.fromJson(json),
        token: _token,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en UsuarioProvider');
        forzarCierreDeSesion();
      } else {
        if (kDebugMode)print('Error al buscar estudiantes: $e');
        _usuarios = [];
      }
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarUsuario(Usuario usuarioEditado) async {
    try {
      final usuarios = await _apiService.actualizar(
        endpoint: 'usuarios',
        documento: usuarioEditado.documento,
        token: _token,
        data: usuarioEditado.toJson(),
      );
      if (usuarios) {
        // Encontrar la posición del usuario en la lista local y reemplazarlo
        final index = _usuarios.indexWhere(
          (u) => u.documento == usuarioEditado.documento,
        );
        if (index != -1) {
          _usuarios[index] = usuarioEditado;
          notifyListeners(); // <-- Esto actualiza la tabla genérica automáticamente
        }
        return true;
      }
      return false;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en UsuarioProvider');
        forzarCierreDeSesion();
      } else {
        if (kDebugMode)print('Error al actualizar usuario: $e');
        _errorMessage = e.toString();
      }
      if (kDebugMode)print('Error al actualiza $e');
      return false;
    }
  }

  Future<void> desactivar(String documento) async {
    final usuarios = await _apiService.eliminarElemnto(
      'usuarios',
      documento,
      _token,
    );

    if (usuarios) {
      final index = _usuarios.indexWhere((u) => u.documento == documento);
      if (index != -1) {
        _usuarios[index] = _usuarios[index].copyWith(activo: false);
        notifyListeners();
      }
    }
  }

  Future<void> activarUsuario(String documento) async {
    final activarUsuario = await _apiService.actualizar(
      endpoint: 'usuarios',
      documento: documento,
      token: _token,
      extencion: 'reactivar',
    );
    if (activarUsuario) {
      final index = _usuarios.indexWhere((u) => u.documento == documento);
      if (index != -1) {
        _usuarios[index] = _usuarios[index].copyWith(activo: true);
        notifyListeners();
      }
    }
  }

  // Cierra sesión y redirige al Login
  void forzarCierreDeSesion() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión expiró. Vuelve a ingresar.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      context.read<AuthProvider>().logout();
    }
    }

    Future<bool> cambiarRol(String docuemnto, String rolCambiado) async {
      try {
        final cambiarRol = await _apiService.actualizar(
          endpoint: 'usuarios',
          documento: docuemnto,
          token: _token,
          extencion: 'rol',
          data: {'rol': rolCambiado},
        );
        if (cambiarRol) {
          final index = _usuarios.indexWhere((u) => u.documento == docuemnto);
          if (index != -1) {
            _usuarios[index] = _usuarios[index].copyWith(rol: rolCambiado);
            notifyListeners();
          }
          return true;
        }

        return false;
      } catch (e) {
        if (kDebugMode) print('Error al actualizar el rol $e');
        return false;
      }
    }
  }

