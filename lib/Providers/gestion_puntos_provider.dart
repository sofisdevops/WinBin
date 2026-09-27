import 'package:flutter/material.dart';
import 'package:winbin/models/users_model.dart';
import 'package:winbin/services/TableServices.dart';

class GestionPuntosProvider extends ChangeNotifier {
  final Tableservices _tableServices = Tableservices();
  
  List<Usuario> _estudiantesEncontrados = [];
  List<Usuario> get estudiantesEncontrados => _estudiantesEncontrados;

  bool _cargando = false;
  bool get cargando => _cargando;

  // cajas de texto para ingresar los datos de busqueda
  final TextEditingController idController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();

  // funcion para consultar estudiantes en la base de datos 
  Future<void> buscarEstudiantes(String? token) async {
    _cargando = true;
    notifyListeners();

    try {
      // ruta para consultar la lista completa
      String endpoint = 'usuarios'; 
      
      final todosLosUsuarios = await _tableServices.traerDatos<Usuario>(
        endpoint: endpoint,
        fromjson: (json) => Usuario.fromJson(json),
        token: token,
      );

      // limpia espacios y pasa a minusculas los textos ingresados
      final textoId = idController.text.trim().toLowerCase();
      final textoNombre = nombreController.text.trim().toLowerCase();

      // filtra la lista segun la identificacion o el nombre ingresado
      _estudiantesEncontrados = todosLosUsuarios.where((estudiante) {
        
        // revisa si el documento coincide o si el campo esta vacio
        bool coincideId = textoId.isEmpty || 
            (estudiante.documento != null && estudiante.documento!.toLowerCase().contains(textoId));
            
        // revisa si el nombre coincide o si el campo esta vacio
        bool coincideNombre = textoNombre.isEmpty || 
            (estudiante.nombre != null && estudiante.nombre!.toLowerCase().contains(textoNombre));

        // conserva a la estudiante si cumple con ambas reglas
        return coincideId && coincideNombre;
        
      }).toList();

    } catch (e) {
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
    _estudiantesEncontrados = [];
    notifyListeners();
  }
}