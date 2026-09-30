import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/main.dart';
import 'package:winbin/models/users_model.dart';
import 'package:winbin/services/TableServices.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/utils/api_exceptions.dart';

class GestionPuntosProvider extends ChangeNotifier {
  final Tableservices _tableServices = Tableservices();

  List<Usuario> _todosLosUsuarios = [];
  List<Usuario> get todosLosEstudiantes => _todosLosUsuarios;

  List<Usuario> _estudiantesEncontrados = [];
  List<Usuario> get estudiantesEncontrados => _estudiantesEncontrados;

  bool _cargando = false;
  bool get cargando => _cargando;

  // cajas de texto para ingresar los datos de busqueda
  final TextEditingController idController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cursoController = TextEditingController();

  // funcion para consultar estudiantes en la base de datos
  Future<void> buscarEstudiantes(String? token) async {
    _cargando = true;
    notifyListeners();

    try {
      // ruta para consultar la lista completa
      String endpoint = 'usuarios';

      // Trae todos los datos y los asigna a la propiedad global
      _todosLosUsuarios = await _tableServices.traerDatos<Usuario>(
        endpoint: endpoint,
        fromjson: (json) => Usuario.fromJson(json),
        token: token,
      );

      // limpia espacios y pasa a minusculas los textos ingresados
      final textoId = idController.text.trim().toLowerCase();
      final textoNombre = nombreController.text.trim().toLowerCase();
      final textoCurso = cursoController.text.trim().toLowerCase();

      // filtra la lista segun la identificacion o el nombre ingresado
      _estudiantesEncontrados = _todosLosUsuarios.where((estudiante) {
        // revisa si el documento coincide o si el campo esta vacio
        bool coincideId =
            textoId.isEmpty ||
            (estudiante.documento != null &&
                estudiante.documento!.toLowerCase().contains(textoId));

        // revisa si el nombre coincide o si el campo esta vacio
        bool coincideNombre =
            textoNombre.isEmpty ||
            (estudiante.nombre != null &&
                estudiante.nombre!.toLowerCase().contains(textoNombre));

        // revisa si el curso coincide o si el campo esta vacio
        bool coincideCurso =
            textoCurso.isEmpty ||
            (estudiante.curso?.nombre != null &&
                estudiante.curso!.nombre!.toLowerCase().contains(textoCurso));

        // conserva a la estudiante si cumple con ambas reglas
        return coincideId && coincideNombre && coincideCurso;
      }).toList();
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en GestionPuntosProvider');
        _forzarCierreDeSesion();
      } else {
        print('Error al buscar estudiantes: $e');
        _estudiantesEncontrados = [];
      }
      print('Error al buscar estudiantes: $e');
      _estudiantesEncontrados = [];
    }

    _cargando = false;
    notifyListeners();
  }

  // vacia las cajas de texto y reinicia los resultados
  void limpiarBusqueda() {
    idController.clear();
    nombreController.clear();
    cursoController.clear();
    _estudiantesEncontrados = [];
    notifyListeners();
  }

  // Cierra sesión y redirige al Login
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
