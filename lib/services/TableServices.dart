import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print(response.body);
      return jsonList.map((item) => fromjson(item)).toList();
    } else {
      throw Exception('Error al cargar datos desde $endpoint');
    }
  }
}
