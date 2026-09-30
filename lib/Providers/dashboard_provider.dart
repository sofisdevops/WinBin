import 'dart:convert';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/utils/api_exceptions.dart';

class DashboardProvider extends ChangeNotifier {
  bool isLoading = true;

  String totalUsuarios = '0';
  String usuariosInactivos = '0';
  String totalCursos = '0';
  String totalMateriales = '0';
  String totalPuntos = '0';

  List<FlSpot> sesionesSpots = [];
  List<String> fechasSesiones = [];

  List<FlSpot> reciclajeSpots = [];
  List<String> fechasReciclaje = [];

  Future<void> cargarResumen(String token) async {
    isLoading = true;

    Future.microtask(() => notifyListeners());

    try {
      final url = Uri.parse(
        '${dotenv.env['BACKEND_API_URL']}/dashboard/resumen-completo',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorizedException(); 
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        totalUsuarios = data['totalUsuarios'].toString();
        usuariosInactivos = data['usuariosInactivos'].toString();
        totalCursos = data['totalCursos'].toString();
        totalMateriales = data['totalMateriales'].toString();
        totalPuntos = data['puntosTotalesUsuarios'].toString();

        _procesarGraficoSesiones(data['sesionesPorDia'] ?? []);
        _procesarGraficoReciclaje(data['reciclajePorDia'] ?? []);
        print('Datos cargados correctamente');
      } else {
        debugPrint('Error al cargar dashboard: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        debugPrint(e.mensaje); 
        _forzarCierreDeSesion();
      } else {
        debugPrint('Error de red o parsing: $e');
      }
      debugPrint('Error al cargar dashboard: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _procesarGraficoSesiones(List<dynamic> datos) {
    sesionesSpots.clear();
    fechasSesiones.clear();
    for (int i = 0; i < datos.length; i++) {
      final cantidad = (datos[i]['cantidad'] as num).toDouble();
      final fechaStr = datos[i]['fecha'].toString();

      sesionesSpots.add(FlSpot(i.toDouble(), cantidad));
      fechasSesiones.add(_formatearFechaCorto(fechaStr));
    }
  }

  void _procesarGraficoReciclaje(List<dynamic> datos) {
    reciclajeSpots.clear();
    fechasReciclaje.clear();
    for (int i = 0; i < datos.length; i++) {
      final cantidad = (datos[i]['cantidad'] as num).toDouble();
      final fechaStr = datos[i]['fecha'].toString();

      reciclajeSpots.add(FlSpot(i.toDouble(), cantidad));
      fechasReciclaje.add(_formatearFechaCorto(fechaStr));
    }
  }

  String _formatearFechaCorto(String fechaDb) {
    try {
      final parts = fechaDb.split('-');
      if (parts.length == 3) {
        final dia = parts[2];
        const meses = [
          '',
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic',
        ];
        final mes = meses[int.parse(parts[1])];
        return '$dia $mes';
      }
    } catch (_) {}
    return fechaDb;
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
