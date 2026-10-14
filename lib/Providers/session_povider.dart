import 'package:flutter/material.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/session_model.dart';
import '../services/TableServices.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class SessionProvider extends ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  final List<DetalleSessionResponse> _sesiones = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _filtroFecha;
  String? _filtroDocumento;
  String? _filtroIdPeriodo;

  List<DetalleSessionResponse> get sesiones => _sesiones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get topUsuarioSesiones {
    if (_sesiones.isEmpty) return 'No hay sesiones registradas';

    Map<String, int> conteoSesiones = {};

    for (var sesion in _sesiones) {
      String identificador = sesion.documento.nombre;

      conteoSesiones[identificador] = (conteoSesiones[identificador] ?? 0) + 1;
    }
    String topUser = 'N/A';
    int maxSesiones = 0;

    conteoSesiones.forEach((user, count) {
      if (count > maxSesiones) {
        maxSesiones = count;
        topUser = user;
      }
    });
    print(topUser);
    print(maxSesiones);

    return '$topUser  ($maxSesiones sesiones)';
  }

  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchSesiones({
    bool refresh = false,
    DateTime? fecha,
    String? documento,
    String? idPeriodo,
  }) async {
    if (refresh) {
      _sesiones.clear();
      _filtroFecha = fecha;
      _filtroDocumento = documento;
      _filtroIdPeriodo = idPeriodo;
      notifyListeners();
    }
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {};
      if (fecha != null) {
        String fechaString =
            "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
        queryParams['fecha'] = fechaString;
      }
      if (documento != null && documento.isNotEmpty) {
        queryParams['documento'] = documento;
      }
      if (idPeriodo != null && idPeriodo.isNotEmpty) {
        queryParams['idPeriodo'] = idPeriodo;
      }

      final listaSesiones = await _apiService
          .traerConParametros<List<DetalleSessionResponse>>(
            endpoint: 'DetalleSession',
            queryParams: queryParams,
            fromjson: (json) => (json as List)
                .map(
                  (e) => DetalleSessionResponse.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
            token: _token,
          );

      listaSesiones.sort((a, b) {
        if (a.fechaHora == null && b.fechaHora == null) return 0;
        if (a.fechaHora == null) return 1;
        if (b.fechaHora == null) return -1;

        return b.fechaHora!.compareTo(a.fechaHora!);
      });
      if (listaSesiones.isNotEmpty) {
        _sesiones.addAll(listaSesiones);
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      _manejarErrores(e);
      _sesiones.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
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
