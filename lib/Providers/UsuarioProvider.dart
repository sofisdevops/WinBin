import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../services/TableServices.dart';
import '../models/users_model.dart';

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
    
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
