import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';

class Tableservices {
  final baseUrl = dotenv.env["BACKEND_API_URL"] ?? '';

  Future<List<T>> traerDatos<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromjson,
    required String? token,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    print(response.statusCode);
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      //print(response.body);
      return jsonList.map((item) => fromjson(item)).toList();
    } else {
      throw Exception('Error al cargar datos desde $endpoint');
    }
  }

  Future<bool> actualizar({
    required String endpoint,
    required dynamic documento,
    required String? token,
    Map<String, dynamic>? data,
    String? extencion,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(
      extencion == null
          ? '$baseUrl/$endpoint/$documento'
          : '$baseUrl/$endpoint/$documento/$extencion',
    );

    final actualizar = data != null
        ? await http.put(url, headers: headers, body: jsonEncode(data))
        : await http.put(url, headers: headers);
    //print('este es el token ${token} ');
    print(
      'datos recubidos ${data}, y este es la respuest del back ${actualizar.body}',
    );

    if (actualizar.statusCode == 401) {
      throw UnauthorizedException();
    }

    return actualizar.statusCode == 200;
  }

  Future<bool> eliminarElemnto(
    String endponit,
    dynamic documento,
    String? token,
  ) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse('$baseUrl/$endponit/$documento'),
      headers: headers,
    );
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    return response.statusCode == 200;
  }

  Future<bool> activarUsuario(
    String endponit,
    dynamic documento,
    String? token,
  ) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse('$baseUrl/$endponit/$documento/reactivar'),
      headers: headers,
    );
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    return response.statusCode == 200;
  }

  Future<bool> crearDato<T>(
    String endpoint,
    Map<String, dynamic> data,
    String? token,
  ) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    String urlString = '$baseUrl/$endpoint';

    final url = Uri.parse(urlString);
    final response = await http.post(
      url,
      body: jsonEncode(data),
      headers: headers,
    );
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    return response.statusCode == 200;
  }
}
