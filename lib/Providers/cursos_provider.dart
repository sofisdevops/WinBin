import 'package:flutter/material.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/auth_model.dart';
import '../services/TableServices.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class CursosProvider extends ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  final List<Curso> _cursos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  List<Curso> get cursos => _cursos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchCursos() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final listaCursos = await _apiService.traerDatos<Curso>(
        endpoint: 'cursos',
        fromjson: (json) => Curso.fromJson(json),
        token: _token,
      );
      _cursos.clear();
      _cursos.addAll(listaCursos);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      _manejarErrores(e);
      _cursos.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> agregarCurso(Curso data) async {
    try {
       Map<String, dynamic> datosJson = data.toJson();
      datosJson.remove('id_curso');
      final response = await _apiService.crearDato(
        'cursos',
        datosJson,
        _token,
      );
      if (response) {
        await fetchCursos();
        return true;
      }
      return false;
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      _manejarErrores(e);
      return false;
    }
  }

  Future<bool> actualizarCurso(Curso cursoEditado) async {
    try {
      final response = await _apiService.actualizarPatch(
        'cursos',
        cursoEditado.id_curso,
        _token,
        cursoEditado.toJson()
      );
      if (response) {
        await fetchCursos();
        return true;
      }
      return false;
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      _manejarErrores(e);
      return false;
    }
  }

  void _manejarErrores(dynamic e) {
    if (e is UnauthorizedException) {
      debugPrint(e.mensaje);
      _forzarCierreDeSesion();
      _errorMessage = 'Error al cargar sesiones: ${e.mensaje}';
    } else {
      _errorMessage = 'Error al cargar sesiones: $e';
    }
  }

  void _forzarCierreDeSesion() {
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
}
