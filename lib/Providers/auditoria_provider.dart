import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:winbin/main.dart';

class AuditoriaProvider with ChangeNotifier {
  StompClient? _stompClient;
  bool _isConnected = false;
  final List<Map<String, dynamic>> _eventosAuditoria = [];

  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get eventos => _eventosAuditoria;

  int get cantidadSinLeer =>
      _eventosAuditoria.where((e) => e['leido'] == false).length;

  void conectar(String token) {
    if (_isConnected) return;

    final String socketUrl = dotenv.env['WS_URL'] ?? '';
    _stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: _onConnectCallback,
        onWebSocketError: (dynamic error) =>
            print('Error de WebSocket: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient?.activate();
  }

  void _onConnectCallback(StompFrame frame) {
    _isConnected = true;
    notifyListeners();

    _stompClient?.subscribe(
      destination: '/topic/auditoria',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          Map<String, dynamic> data = json.decode(frame.body!);
          data['leido'] = false;
          _eventosAuditoria.insert(0, data);
          notifyListeners();
        }
      },
    );
  }

  void marcarComoLeido(int index) {
    if (_eventosAuditoria[index]['leido'] == false) {
      _eventosAuditoria[index]['leido'] = true;
      notifyListeners();
    }
  }

  void marcarTodasComoLeidas() {
    for (var evento in _eventosAuditoria) {
      evento['leido'] = true;
    }
    notifyListeners();
  }

  void desconectar() {
    _stompClient?.deactivate();
    _isConnected = false;
    notifyListeners();
  }
  final String apiUrl = dotenv.env['BACKEND_API_URL'] ?? '';

  Future<void> cargarHistorial(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apiUrl/auditoria?page=0&size=15&sort=fecha,desc',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorizedException();
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        
        final List<dynamic> content = body['content'] ?? [];

        _eventosAuditoria.clear();
        
        final historialCargado = content.map((e) {
          final aud = e as Map<String, dynamic>;
          
          String usuario = 'Sistema';
          if (aud['documento'] != null && aud['documento']['documento'] != null) {
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
            'fecha': aud['fecha'] ?? 'Sin fecha',
            'leido': true,
          };
        }).toList();
        _eventosAuditoria.addAll(historialCargado);
        
        notifyListeners();
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        debugPrint(e.mensaje); 
        _forzarCierreDeSesion();
      } else {
        debugPrint('Error de red o parsing: $e');
      }
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
