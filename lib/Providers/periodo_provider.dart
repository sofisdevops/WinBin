import 'package:flutter/material.dart';
import '../services/TableServices.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/perido_model.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class PeriodoProvider extends ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  List<Periodo> _periodos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Periodo> get periodos => _periodos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchPeriodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _periodos = await _apiService.traerDatos<Periodo>(
        endpoint: 'PeriodoRanking',
        fromjson: (json) => Periodo.fromJson(json),
        token: _token,
      );

      _periodos.sort((a, b) {
        if (a.fechaInicio == null && b.fechaInicio == null) return 0;
        if (a.fechaInicio == null) return 1;
        if (b.fechaInicio == null) return -1;

        return b.fechaInicio!.compareTo(a.fechaInicio!);
      });
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en UsuarioProvider');
        _forzarCierreDeSesion();
      } else {
        print('Error al buscar periodos: $e');
        _periodos = [];
      }
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarPeriodo(Periodo periodoEditado) async {
    try {
      final response = await _apiService.actualizarPatch(
        'PeriodoRanking',
        periodoEditado.idPeriodo,
        _token,
        periodoEditado.toJson(),
      );
      if (response) {
        await fetchPeriodos();
        return true;
      }
      return false;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en UsuarioProvider');
        _forzarCierreDeSesion();
      } else {
        print('Error al actualizar periodo: $e');
        _periodos = [];
      }
      return false;
    }
  }

  Future<bool> crearPeriodo(Periodo data) async {
    try {
      Map<String, dynamic> datosJson = data.toJson();
      datosJson.remove('id_periodo');
      final response = await _apiService.crearDato(
        'PeriodoRanking',
        datosJson,
        _token,
      );
      if (response) {
        await fetchPeriodos();
        return true;
      }
      return false;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en UsuarioProvider');
        _forzarCierreDeSesion();
      } else {
        print('Error al crear periodo: $e');
      }
      return false;
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
