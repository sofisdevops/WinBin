import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class UsuarioService {
  static final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static final String backendUrl = dotenv.env['BACKEND_API_URL'] ?? '';

  Future<String?> actualizarAvatar(XFile imageFile, String token) async {
    try {
      final cloudRequest = http.MultipartRequest(
        'POST',
        Uri.parse(cloudinaryUrl),
      )..fields['upload_preset'] = uploadPreset;

      final bytes = await imageFile.readAsBytes();

      cloudRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );

      final cloudResponse = await cloudRequest.send();

      if (cloudResponse.statusCode != 200 && cloudResponse.statusCode != 201) {
        if (kDebugMode)print('Error en Cloudinary: ${cloudResponse.statusCode}');
        return null;
      }

      final cloudData = await cloudResponse.stream.bytesToString();
      final cloudJson = json.decode(cloudData);
      final String imageUrl = cloudJson['secure_url'];

      final apiResponse = await http.patch(
        Uri.parse('$backendUrl/usuarios/avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'avatarUrl': imageUrl}),
      );

      if (apiResponse.statusCode == 200) {
        return imageUrl;
      }
      if (apiResponse.statusCode == 401) {
        throw UnauthorizedException();
      } else {
       if (kDebugMode) print('Error en la API: ${apiResponse.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      if (kDebugMode)print('Excepción en UsuarioService: $e');
      return null;
    }
  }

  Future<bool>cambiarPassword( String token,String passwordActual, String passwordNueva)async{
    try {
      final response = await http.put(
        Uri.parse('$backendUrl/usuarios/perfil/cambiar-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'passwordActual': passwordActual,
          'nuevaPassword': passwordNueva,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } 
      else if(response.statusCode == 401){
        throw UnauthorizedException();
      }

      else {
        if (kDebugMode)print('Error al cambiar password: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if(e is UnauthorizedException) rethrow;
      if (kDebugMode)print('Excepción en cambiarPassword: $e');
      return false;
    }
  }
}
