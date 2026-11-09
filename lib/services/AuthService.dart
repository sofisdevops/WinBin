import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/models/session_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:flutter/foundation.dart';


class AuthService {
  static final String baseUrl = dotenv.env['BACKEND_API_URL'] ?? '';

  Future<LoginResponse?> login(String documento, String contrasenna) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'documento': documento, 'contrasenna': contrasenna}),
      );
      
      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        if (kDebugMode) print('Error al iniciar sesión: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
      if (kDebugMode) print('Error al iniciar sesión: $e');
      return null;
    }
  }

  Future<DetalleSessionResponse?> detalleSession({
  required String documento,
  required String idPeriodo,
  required String token,
 } ) async {
    final url = Uri.parse('$baseUrl/DetalleSession');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'documento': {'documento': documento},
          'id_periodo': {'id_periodo': idPeriodo},
        }),
      );

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DetalleSessionResponse.fromJson(data);
      } else {
        if (kDebugMode) print('Error al obtener detalles del usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
       if (kDebugMode) print('Error al obtener detalles del usuario: $e');
      return null;
    }
  }
  Future<List<Curso>?> getCursos() async {
    final url = Uri.parse('$baseUrl/cursos');

    try {
      final response = await http.get(url);

      if (response.statusCode == 401 ) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Curso.fromJson(json)).toList();
      } else {
        if (kDebugMode) print('Error al obtener cursos: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
      if (kDebugMode) print('Excepción al obtener cursos: $e');
      return null;
    }
  }

 

  Future<UsuarioPerfil?> obtenerPerfil({required String token}) async {
    final url = Uri.parse('$baseUrl/usuarios/perfil');

    try {
      final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
      );
      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        return UsuarioPerfil.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode)print('Error al obtener perfil: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
      if (kDebugMode) print('Excepción al obtener perfil: $e');
      return null;
    }
  }


  Future<Periodo?> getPeriodo({required String token}) async {
    final url = Uri.parse('$baseUrl/PeriodoRanking/activo');

    try {
      final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      );
      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Periodo.fromJson(data);
      } else {
        if (kDebugMode) print('Error al obtener periodo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
      if (kDebugMode) print('Excepción al obtener periodo: $e');
      return null;
    }
  }

  Future<bool> registrarUsuario(
    String documento,
    String nombre,
    int cursoId,
    String contrasenna,
    String? avatarUrl,
  ) async {
    final url = Uri.parse('$baseUrl/usuarios/registro');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'documento': documento,
          'nombre': nombre,
          'id_curso': cursoId,
          'contrasenna': contrasenna,
          'avatarUrl': avatarUrl ?? "",
        }),
      );
        if (response.statusCode == 401) {
          throw UnauthorizedException();
      }
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode)print('Error en registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
      if (kDebugMode) print('Excepción al conectar con el servidor: $e');
      return false;
    }
  }

  
}
