import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../services/TableServices.dart';
import '../models/users_model.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/puntajeCtaegoria_model.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/Providers/UsuarioProvider.dart';

class CategoriaPuntajeProvider extends ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  List<PuntajeCategoria> _puntajeCategorias = [];
  List<PuntajeCategoria> get puntajeCategorias => _puntajeCategorias;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;

  // Método para recibir el token actualizado del AuthProvider
  void updateToken(String? token) {
    _token = token;
  }

  // Cargar datos de la BD externa
  Future<void> fetchPuntajeCategorias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _puntajeCategorias = await _apiService.traerDatos<PuntajeCategoria>(
        endpoint: 'CategoriaPuntaje',
        fromjson: (json) => PuntajeCategoria.fromJson(json),
        token: _token,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en CategoriaPuntajeProvider');
        UsuarioProvider().forzarCierreDeSesion();
      } else {
        print('Error al buscar categorias de puntaje: $e');
        _puntajeCategorias = [];
      }
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final Map<int, int> _cambiosPendientes = {};

  
  void registrarCambioPuntaje(int idCategoria, int nuevosPuntos) {
    _cambiosPendientes[idCategoria] = nuevosPuntos; 
    

    notifyListeners(); 
  }


  void actualizarPuntajeLocal(int idCategoriaPuntaje, int nuevosPuntos) {
    // Buscamos el elemento y actualizamos en la lista local
    final index = _puntajeCategorias.indexWhere(
      (item) => item.id_categoria == idCategoriaPuntaje,
    );

    if (index != -1) {
      _puntajeCategorias[index].puntos = nuevosPuntos;
      _cambiosPendientes[idCategoriaPuntaje] = nuevosPuntos;
      notifyListeners();
    }
  }

  Future<bool> guardarCambiosPuntajes() async {
    if (_cambiosPendientes.isEmpty) return true; // Nada que guardar

    _isLoading = true;
    notifyListeners();
    try {
      // Estructuramos el payload para el Backend
      final listaActualizaciones = _cambiosPendientes.entries.map((entry) async {
       final int id_categoria = entry.key; 
       final int puntos= entry.value;
        return await _apiService.actualizarPatch(
        'CategoriaPuntaje',
        id_categoria,
        _token,
        {'puntos':puntos},
      );
      }).toList();

      
      final resultados = await Future.wait(listaActualizaciones);

    // Verificas si todas las peticiones fueron exitosas (true)
    final todoExitoso = resultados.every((exito) => exito == true);

    if (todoExitoso) {
      _cambiosPendientes.clear();
    }

      _isLoading = false;
      notifyListeners();
      return todoExitoso;
    } catch (e) {
      _errorMessage = 'Error al guardar los cambios: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
