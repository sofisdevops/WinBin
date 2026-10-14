import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:winbin/main.dart';
import '../models/ranking_model.dart';

class RankingProvider with ChangeNotifier {

  
  StompClient? _stompClient;
  bool _isConnected = false;

  bool _hasWsError = false;
  bool get hasWsError => _hasWsError;

  // TOP 10 (WebSockets y Carga Inicial)
  List<dynamic> _topEstudiantes = [];
  List<dynamic> _topCursos = [];

  List<dynamic> get topEstudiantes => _topEstudiantes;
  List<dynamic> get topCursos => _topCursos;
  bool get isConnected => _isConnected;

  String get mejorEstudiante {
    if (_topEstudiantes.isEmpty) return 'No hay estudiantes';
    final top = _topEstudiantes.first;
    String nombreUsuario = top['nombre'] ?? 'No disponible';
    String puntosUsuario = top['puntos'].toString();
    return '$nombreUsuario ($puntosUsuario puntos)';
  }

  String get mejorCurso {
    if (_topCursos.isEmpty) return 'No hay cursos';
    final top = _topCursos.first;
    String nombreCurso = top['nombreCurso'] ?? 'No disponible';
    String puntosCurso = top['puntosTotales'].toString();
    return '$nombreCurso ($puntosCurso puntos)';
  }

  // Paginación de Estudiantes
  List<RankingUserModel> _usuarios = [];
  bool _isLoading = false;
  int _currentPage = 1; 
  bool _hasMoreData = true;

  List<RankingUserModel> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  // ESTADO: Paginación de Cursos
  List<CursoModel> _cursosPaginados = [];
  bool _isLoadingCursos = false;
  int _currentPageCursos = 1; 
  bool _hasMoreDataCursos = true;

  List<CursoModel> get cursosPaginados => _cursosPaginados;
  bool get isLoadingCursos => _isLoadingCursos;
  bool get hasMoreDataCursos => _hasMoreDataCursos;

  /// Método de notificación segura para evitar colisiones en Flutter Web
  void _safeNotifyListeners() {
    if (!hasListeners) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  // Paginación de Estudiantes
  Future<void> fetchRanking(String token, {bool refresh = false}) async {
    if (_isLoading || (!_hasMoreData && !refresh)) return;

    if (refresh) {
      _currentPage = 1;
      _usuarios.clear();
      _hasMoreData = true;
    }

    _isLoading = true;
    _safeNotifyListeners(); 

    try {
      final String baseUrl = dotenv.env['BACKEND_API_URL'] ?? ''; 
      final url = Uri.parse('$baseUrl/ranking/usuarios/paginado?page=$_currentPage');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        List dataList = json.decode(utf8.decode(response.bodyBytes));

        if (dataList.isEmpty) {
          _hasMoreData = false; 
        } else {
          final nuevosUsuarios = dataList.map((json) => RankingUserModel.fromJson(json)).toList();
          _usuarios.addAll(nuevosUsuarios);
          _currentPage++; 
        }
      } else {
        print('Error en la API de estudiantes: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        debugPrint(e.mensaje); 
        _forzarCierreDeSesion();
      } else {
        debugPrint('Error de red o parsing (Estudiantes): $e');
      }
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Paginación de Cursos
  Future<void> fetchRankingCursos(String token, {bool refresh = false}) async {
    if (_isLoadingCursos || (!_hasMoreDataCursos && !refresh)) return;

    if (refresh) {
      _currentPageCursos = 1;
      _cursosPaginados.clear();
      _hasMoreDataCursos = true;
    }

    _isLoadingCursos = true;
    _safeNotifyListeners(); 

    try {
      final String baseUrl = dotenv.env['BACKEND_API_URL'] ?? ''; 
      final url = Uri.parse('$baseUrl/ranking/cursos/paginado?page=$_currentPageCursos');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        List dataList = json.decode(utf8.decode(response.bodyBytes));

        if (dataList.isEmpty) {
          _hasMoreDataCursos = false; 
        } else {
          final nuevosCursos = dataList.map((json) => CursoModel.fromJson(json)).toList();
          _cursosPaginados.addAll(nuevosCursos);
          _currentPageCursos++; 
        }
      } else {
        print('Error en la API de cursos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        debugPrint(e.mensaje); 
        _forzarCierreDeSesion();
      } else {
        debugPrint('Error de red o parsing (Cursos): $e');
      }
    } finally {
      _isLoadingCursos = false;
      _safeNotifyListeners();
    }
  }

  // Top 10 Inicial
  Future<void> cargarRankingsIniciales(String token) async {
    try {
      final String apiUrl = dotenv.env['BACKEND_API_URL'] ?? '';
      
      // Top 10 Estudiantes
      final resEstudiantes = await http.get(
        Uri.parse('$apiUrl/ranking/top10/estudiantes'), 
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resEstudiantes.statusCode == 401 || resEstudiantes.statusCode == 403) {
        throw UnauthorizedException();
      }
      if (resEstudiantes.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(resEstudiantes.bodyBytes));
        if (decodedData is List) {
          _topEstudiantes = decodedData;
        }
      }

      final resCursos = await http.get(
        Uri.parse('$apiUrl/ranking/top10/cursos'), 
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resCursos.statusCode == 401 || resCursos.statusCode == 403) {
        throw UnauthorizedException();
      }
      if (resCursos.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(resCursos.bodyBytes));
        if (decodedData is List) {
          _topCursos = decodedData;
        }
      }

      _safeNotifyListeners();
    } catch (e) {
      if (e is UnauthorizedException) {
        debugPrint(e.mensaje); 
        _forzarCierreDeSesion();
      } else {
        debugPrint('Error cargando rankings iniciales: $e');
      }
    }
  }

  // WebSockets
  void conectar(String token) async {
    if (_isConnected) return;
    _hasWsError = false;
    await cargarRankingsIniciales(token);

    final String socketUrl = dotenv.env['WS_URL'] ?? '';

    _stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        onConnect: (StompFrame frame) {
          _isConnected = true;
          _hasWsError = false;
          print("¡CONEXIÓN WS LISTA EN PROVIDER TOP 10!");
          _safeNotifyListeners();
          
          _stompClient?.subscribe(
            destination: '/topic/ranking/estudiantes-top10',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  _topEstudiantes = json.decode(frame.body!);
                  _safeNotifyListeners(); 
                } catch (e) {
                  print(" ERROR PARSEANDO LISTA ESTUDIANTES WS: $e");
                }
              }
            },
          );

          _stompClient?.subscribe(
            destination: '/topic/ranking/cursos-top10',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  _topCursos = json.decode(frame.body!);
                  _safeNotifyListeners();
                } catch (e) {
                  print(" ERROR PARSEANDO LISTA CURSOS WS: $e");
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          debugPrint('Error WS Ranking: $error');
          _hasWsError = true;
          _safeNotifyListeners();
        },
        onDisconnect: (frame) {
          _isConnected = false;
          _safeNotifyListeners();
        },
      ),
    );

    _stompClient?.activate();
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

  // Utilidades
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