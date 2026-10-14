import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:winbin/main.dart';
import 'package:winbin/services/TableServices.dart';
import 'package:winbin/models/auditoria_model.dart';

class AuditoriaProvider with ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  bool _hasWsError = false;
  bool get hasWsError => _hasWsError;

  // Estados notificaciones
  StompClient? _stompClient;
  bool _isConnected = false;
  final List<Map<String, dynamic>> _eventosAuditoria = [];

  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get eventos => _eventosAuditoria;

  int get cantidadSinLeer =>
      _eventosAuditoria.where((e) => e['leido'] == false).length;

  // Estados tabla auditoria
  final List<Auditoria> _auditoriasTabla = [];
  int _currentPageTabla = 0;
  bool _isLastPageTabla = false;
  bool _isLoadingTabla = false;
  String? _filtroAccionTabla;
  String? _token;

  String? _errorMessageTabla;

  String? get errorMessageTabla => _errorMessageTabla;
  bool get isLoadingTabla => _isLoadingTabla;
  bool get hasMoreTabla => !_isLastPageTabla;
  List<Auditoria> get auditoriasTabla => _auditoriasTabla;

  void updateToken(String? token) {
    _token = token;
  }

  void _safeNotifyListeners() {
    if (!hasListeners) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  void conectar(String token) {
    if (_isConnected) return;
    _hasWsError = false;

    final String socketUrl = dotenv.env['WS_URL'] ?? '';
    _stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: _onConnectCallback,
        onWebSocketError: (dynamic error) {
          debugPrint('Error de WebSocket: $error');
          _hasWsError = true;
          _safeNotifyListeners();
        },
        onDisconnect: (frame) {
          _isConnected = false;
          _safeNotifyListeners();
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient?.activate();
  }

  void _onConnectCallback(StompFrame frame) {
    _isConnected = true;
    _hasWsError = false;
    _safeNotifyListeners();

    _stompClient?.subscribe(
      destination: '/topic/auditoria',
      callback: (StompFrame frame) {
        if (frame.body != null && frame.body!.isNotEmpty) {
          try {
            final decoded = json.decode(frame.body!);
            if (decoded is Map) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(
                decoded,
              );
              data['leido'] = false;

              _eventosAuditoria.insert(0, data);
              _safeNotifyListeners();
            } else if (decoded is List) {
              for (var item in decoded) {
                if (item is Map) {
                  final Map<String, dynamic> data = Map<String, dynamic>.from(
                    item,
                  );
                  data['leido'] = false;
                  _eventosAuditoria.insert(0, data);
                }
              }
              _safeNotifyListeners();
            }
          } catch (e) {
            print("Error decodificando notificación auditoría: $e");
          }
        }
      },
    );
  }

  void marcarComoLeido(int index) {
    if (index >= 0 && index < _eventosAuditoria.length) {
      if (_eventosAuditoria[index]['leido'] == false) {
        _eventosAuditoria[index]['leido'] = true;
        _safeNotifyListeners();
      }
    }
  }

  void marcarTodasComoLeidas() {
    for (var evento in _eventosAuditoria) {
      evento['leido'] = true;
    }
    _safeNotifyListeners();
  }

  void desconectar() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    _stompClient = null;
    super.dispose();
  }

  final String apiUrl = dotenv.env['BACKEND_API_URL'] ?? '';

  Future<void> cargarHistorial(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/auditoria?page=0&size=15&sort=fecha,desc'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorizedException();
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(
          utf8.decode(response.bodyBytes),
        );

        final List<dynamic> content = body['content'] ?? [];

        _eventosAuditoria.clear();

        final historialCargado = content.map((e) {
          final aud = e as Map<String, dynamic>;

          String usuario = 'Sistema';
          if (aud['documento'] != null &&
              aud['documento']['documento'] != null) {
            usuario = aud['documento']['documento'].toString();
          }

          String tabla = aud['tablaAfectada'] ?? 'Desconocida';
          String accion = aud['accion'] ?? 'ACCION';

          String accionTexto = 'realizó una acción en';
          if (accion == 'INSERT') accionTexto = 'creó un registro en';
          if (accion == 'UPDATE') accionTexto = 'actualizó un registro en';
          if (accion == 'DELETE') accionTexto = 'eliminó un registro de';

          return {
            'accion': accion,
            'tabla': tabla,
            'usuario': usuario,
            'mensaje': '$usuario $accionTexto $tabla',
            'fecha': aud['fecha']?.toString() ?? 'Sin fecha',
            'leido': true,
          };
        }).toList();

        _eventosAuditoria.addAll(historialCargado);
        _safeNotifyListeners();
      }
    } catch (e) {
      _manejarErrores(e);
    }
  }

  // Métodos de Tabla
  Future<void> cargarTabla({bool refresh = false, String? accionFiltro}) async {
    if (refresh) {
      _currentPageTabla = 0;
      _isLastPageTabla = false;
      _auditoriasTabla.clear();
      _filtroAccionTabla = accionFiltro;
    }

    if (_isLoadingTabla || _isLastPageTabla) return;

    _isLoadingTabla = true;
    _safeNotifyListeners();

    try {
      final Map<String, dynamic> parametros = {
        'page': _currentPageTabla,
        'size': 10000,
        'sort': 'fecha,desc',
      };
      if (_filtroAccionTabla != null && _filtroAccionTabla!.isNotEmpty) {
        parametros['accion'] = _filtroAccionTabla;
      }

      final AuditoriaPage pagina = await _apiService
          .traerConParametros<AuditoriaPage>(
            endpoint: 'auditoria',
            queryParams: parametros,
            fromjson: (json) => AuditoriaPage.fromJson(json),
            token: _token,
          );

      if (pagina.content != null) {
        _auditoriasTabla.addAll(pagina.content!);
      }

      _isLastPageTabla = pagina.last ?? true;
      _currentPageTabla++;
    } catch (e) {
      _manejarErrores(e);
    } finally {
      _isLoadingTabla = false;
      _safeNotifyListeners();
    }
  }

  void _manejarErrores(dynamic e) {
    if (e is UnauthorizedException) {
      debugPrint(e.mensaje);
      _forzarCierreDeSesion();
      _errorMessageTabla = 'Error al cargar auditorias: ${e.mensaje}';
    } else {
      _errorMessageTabla = 'Error al cargar auditorias: $e';
    }
    _safeNotifyListeners();
  }

  void _forzarCierreDeSesion() {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
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
