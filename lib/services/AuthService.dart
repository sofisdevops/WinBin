import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:winbin/models/auth_model.dart';
import 'package:winbin/models/session_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


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

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Login exitoso: ${data}');
        return LoginResponse.fromJson(data);
      } else {
        print('Error al iniciar sesión: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Detalle de sesión creado/obtenido con éxito: $data');
        return DetalleSessionResponse.fromJson(data);
      } else {
        print('Error al obtener detalles del usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener detalles del usuario: $e');
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

      if (response.statusCode == 200) {
        print('perfiles obtenidos :${response.body}');
        return UsuarioPerfil.fromJson(jsonDecode(response.body));
      } else {
        print('Error al obtener perfil: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener perfil: $e');
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Periodo obtenido : $data');
        return Periodo.fromJson(data);
      } else {
        print('Error al obtener periodo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener periodo: $e');
      return null;
    }
  }

  Future<bool> registrarUsuario(
    String documento,
    String nombre,
    int cursoId,
    String contrasenna,
  ) async {
    final url = Uri.parse('$baseUrl/usuarios/registro');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'documento': documento,
          'nombre': nombre,
          'curso': {'id_curso': cursoId},
          'contrasenna': contrasenna,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Usuario registrado con éxito');
        return true;
      } else {
        print('Error en registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Excepción al conectar con el servidor: $e');
      return false;
    }
  }

  
}
