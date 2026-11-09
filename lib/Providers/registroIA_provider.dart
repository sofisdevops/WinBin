import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/main.dart';
import 'package:winbin/models/registroIA_model.dart';
import 'package:winbin/models/users_model.dart';
import 'package:winbin/services/TableServices.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/utils/api_exceptions.dart';
import 'package:flutter/foundation.dart';

class RegistroiaProvider extends ChangeNotifier {
  final Tableservices _tableServices = Tableservices();

  List<RegistroiaModel> _todosLosRegistros = [];
  List<RegistroiaModel> get todosLosRegistris => _todosLosRegistros;

  List<RegistroiaModel> _registrosEncontrados = [];
  List<RegistroiaModel> get registrosEncontrados => _registrosEncontrados;

  bool _cargando = false;
  bool get cargando => _cargando;

  String get topMaterialesRegistros {
    if(_todosLosRegistros.isEmpty) return 'No hay registros';
    Map<int, int> cantidadPorMaterial = {};

    for(var registro in _todosLosRegistros) {
     int material = registro.material!.id_material!;
      cantidadPorMaterial[material] = (cantidadPorMaterial[material] ?? 0) + 1;
    }

    int topMaterial = 0;
    int Maximo = 0;

    cantidadPorMaterial.forEach((id_material, count) {
      if (count > Maximo) {
        Maximo = count;
        topMaterial = id_material;
      }
    });
    return '${_todosLosRegistros.firstWhere((registro) => registro.material!.id_material == topMaterial).material!.nombreMaterial} ($Maximo Registro)';
  }

  // cajas de texto para ingresar los datos de busqueda
  final TextEditingController NombreMaterialController =
      TextEditingController();
  //final TextEditingController fechaController = TextEditingController();
  final TextEditingController confianzaController = TextEditingController();
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime? _seletedFecha;
  DateTime? get seletedFecha => _seletedFecha;

  set seletedFecha(DateTime? fecha) {
    _seletedFecha = fecha;
  }

  // funcion para consultar estudiantes en la base de datos
  Future<void> fetchUsuarios(String? token) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todosLosRegistros = await _tableServices.traerDatos<RegistroiaModel>(
        endpoint: 'registroia',
        fromjson: (json) => RegistroiaModel.fromJson(json),
        token: token,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en UsuarioProvider');
        _forzarCierreDeSesion();
      } else {
        if (kDebugMode)print('Error al buscar estudiantes: $e');
        _todosLosRegistros = [];
      }
      _errorMessage = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> buscarRegistro(String? token) async {
    _cargando = true;
    notifyListeners();

    try {
      // Trae todos los datos y los asigna a la propiedad global
      _todosLosRegistros = await _tableServices.traerDatos<RegistroiaModel>(
        endpoint: 'registroia',
        fromjson: (json) => RegistroiaModel.fromJson(json),
        token: token,
      );

      // limpia espacios y pasa a minusculas los textos ingresados
      final NombreMaterial = NombreMaterialController.text.trim().toLowerCase();
      
      final confianza = confianzaController.text.trim().toLowerCase();

      // filtra la lista segun la identificacion o el nombre ingresado
      _registrosEncontrados = _todosLosRegistros.where((registro) {
        // revisa si el documento coincide o si el campo esta vacio
        bool coincideMaterial =
            NombreMaterial.isEmpty ||
            (registro.material?.nombreMaterial != null &&
                registro.material!.nombreMaterial.toLowerCase().contains(
                  NombreMaterial,
                ));

         bool coincideFecha = _seletedFecha == null;
        if (_seletedFecha != null && registro.session?.fechaHora != null) {
          DateTime fechaReg = registro.session!.fechaHora!;
          coincideFecha = fechaReg.year == _seletedFecha!.year &&
              fechaReg.month == _seletedFecha!.month &&
              fechaReg.day == _seletedFecha!.day;
        }

        bool coincideConfianza =
            confianza.isEmpty ||
            (registro.confianza != null &&
                registro.confianza.toString().toLowerCase().contains(
                  confianza,
                ));

        // conserva a la estudiante si cumple con ambas reglas
        return coincideMaterial && coincideFecha && coincideConfianza;
      }).toList();
    } catch (e) {
      if (e is UnauthorizedException) {
        print('Sesión expirada detectada en GestionPuntosProvider');
        _forzarCierreDeSesion();
      } else {
       if (kDebugMode) print('Error al buscar estudiantes: $e');
        _registrosEncontrados = [];
      }
      if (kDebugMode)print('Error al buscar estudiantes: $e');
      _registrosEncontrados = [];
    }

    _cargando = false;
    notifyListeners();
  }

  // vacia las cajas de texto y reinicia los resultados
  Future<void> limpiarBusqueda() async{
    NombreMaterialController.clear();
    _seletedFecha = null;
    confianzaController.clear();
    _registrosEncontrados = [];
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
