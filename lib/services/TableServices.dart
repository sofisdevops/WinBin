import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:flutter/foundation.dart';

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
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> jsonList = [];

      if (decodedData is Map<String, dynamic> &&
          decodedData.containsKey('content')) {
        jsonList = decodedData['content'];
      }
      // O si directamente es una lista rasa
      else if (decodedData is List) {
        jsonList = decodedData;
      }

      return jsonList.map((item) => fromjson(item)).toList();
    } else {
      throw Exception('Error al cargar datos desde $endpoint');
    }
  }

  Future<T> traerConParametros<T>({
    required String endpoint,
    required T Function(dynamic json) fromjson,
    required String? token,
    Map<String, dynamic>? queryParams,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    Uri uri = Uri.parse('$baseUrl/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      final Map<String, String> stringParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      uri = uri.replace(queryParameters: stringParams);
    }
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode == 200) {
      final dynamic jsonMap = jsonDecode(response.body);
      return fromjson(jsonMap);
    } else {
      throw Exception('Error al cargar datos desde $endpoint');
    }
  }

  Future<List<T>> traerListaConParametros<T>({
    required String endpoint,
    required T Function(dynamic json) fromjson,
    required String? token,
    Map<String, dynamic>? queryParams,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    Uri uri = Uri.parse('$baseUrl/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      final Map<String, String> stringParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      uri = uri.replace(queryParameters: stringParams);
    }
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => fromjson(item)).toList();
    } else {
      throw Exception('Error al cargar lista desde $endpoint');
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

  Future<bool> actualizarPatch(
    String endponit,
    dynamic id,
    String? token,
    dynamic data,
  ) async {
    final url = Uri.parse('$baseUrl/$endponit/$id');

    try {
      final bodyData = jsonEncode(data);

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: bodyData,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        if (kDebugMode) print('Error en la API (${response.statusCode})');
        return false;
      }
    } catch (e) {
       if (kDebugMode)print('Error al conectar con el servidor: $e');
      return false;
    }
  }
}
