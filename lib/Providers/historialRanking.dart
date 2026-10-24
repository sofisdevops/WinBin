import 'package:flutter/material.dart';
import '../services/TableServices.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:winbin/main.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/historial_ranking.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class HistorialRankingProvider extends ChangeNotifier {
  final Tableservices _apiService = Tableservices();

  List<HistorialRanking> _historiales = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HistorialRanking> get historiales => _historiales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchHistoriales(String idPeriodo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final List<HistorialRanking> historiales = await _apiService.traerListaConParametros<HistorialRanking>(
        endpoint: 'HistorialGanadores',
        fromjson: (json) => HistorialRanking.fromJson(json),
        token: _token,
        queryParams: {'idPeriodo': idPeriodo}
      );

      _historiales = historiales;

    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en HistorialRankingProvider');
        _forzarCierreDeSesion();
      } else {
        print('Error al buscar historiales de ranking: $e');
        _historiales = [];
      }
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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