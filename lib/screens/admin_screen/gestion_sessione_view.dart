import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/session_model.dart';
import 'package:winbin/Providers/session_povider.dart';
import 'package:winbin/screens/admin_screen/widgets_admin/tablaGenerica.dart';
import '../../utils/formatear_hora.dart';
import 'package:winbin/Providers/periodo_provider.dart';

class GestionSessionView extends StatefulWidget {
  const GestionSessionView({super.key});

  @override
  State<GestionSessionView> createState() => _GestionSessionViewState();
}

class _GestionSessionViewState extends State<GestionSessionView> {
  final TextEditingController _documentoController = TextEditingController();
  DateTime? _selectedFecha;
  String? _selectedPeriodoId;
  bool _isLoadingPeriodos = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().fetchSesiones(refresh: true);
      _cargarPeriodos();
    });
  }

  Future<void> _cargarPeriodos() async {
    try {
      final periodoProvider = Provider.of<PeriodoProvider>(context, listen: false);
      await periodoProvider.fetchPeriodos();
      setState(() {
        _isLoadingPeriodos = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPeriodos = false;
      });
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFecha ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedFecha) {
      setState(() {
        _selectedFecha = picked;
      });
    }
  }

  void _ejecutarBusqueda() {
    final documento = _documentoController.text.trim();
    context.read<SessionProvider>().fetchSesiones(
      refresh: true,
      documento: documento.isEmpty ? null : documento,
      fecha: _selectedFecha,
      idPeriodo: _selectedPeriodoId,
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _documentoController.clear();
      _selectedFecha = null;
      _selectedPeriodoId = null;
    });
    context.read<SessionProvider>().fetchSesiones(refresh: true);
  }

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final periodoProvider = context.watch<PeriodoProvider>();
    final periodos = periodoProvider.periodos;

    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.sesiones.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Gestión de Sesiones',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Filtra y administra el historial de sesiones del sistema.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // TARJETA DE FILTROS EN FILA HORIZONTAL
              Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.filter_list, color: Color(0xFF1B5E20), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Filtros de Búsqueda',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            child: TextField(
                              controller: _documentoController,
                              decoration: InputDecoration(
                                labelText: 'Documento de usuario',
                                prefixIcon: const Icon(Icons.person_search, color: Color(0xFF2E7D32), size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),

                          // 2. Selector de Fecha
                          SizedBox(
                            width: 220,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarFecha(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2E7D32)),
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedFecha == null
                                          ? 'Seleccionar Fecha'
                                          : '${_selectedFecha!.day}/${_selectedFecha!.month}/${_selectedFecha!.year}',
                                      style: TextStyle(
                                        color: _selectedFecha == null ? Colors.black54 : Colors.black87,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_selectedFecha != null)
                                    InkWell(
                                      onTap: () => setState(() => _selectedFecha = null),
                                      child: const Icon(Icons.clear, size: 16, color: Colors.red),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // 3. Dropdown de Periodos
                          SizedBox(
                            width: 250,
                            child: _isLoadingPeriodos
                                ? const LinearProgressIndicator(color: Color(0xFF2E7D32))
                                : DropdownButtonFormField<String>(
                                    value: _selectedPeriodoId,
                                    decoration: InputDecoration(
                                      labelText: 'Periodo de Ranking',
                                      prefixIcon: const Icon(Icons.date_range, color: Color(0xFF2E7D32), size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Todos los periodos', style: TextStyle(color: Colors.grey)),
                                      ),
                                      ...periodos.map((periodo) {
                                        return DropdownMenuItem<String>(
                                          value: periodo.idPeriodo.toString(),
                                          child: Text(
                                            periodo.nombrePeriodo ?? periodo.idPeriodo.toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? nuevoValor) {
                                      setState(() {
                                        _selectedPeriodoId = nuevoValor;
                                      });
                                    },
                                  ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _limpiarFiltros,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                                label: const Text('Limpiar', style: TextStyle(color: Colors.black87)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _ejecutarBusqueda,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.search, size: 18),
                                label: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Resultados de Búsqueda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${provider.sesiones.length} Encontradas',
                              style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFFC8E6C9),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      if (provider.sesiones.isEmpty) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text(
                              'No hay sesiones con estos filtros',
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                            ),
                          ),
                        ),
                      ] else ...[
                        GenericTable<DetalleSessionResponse>(
                          title: 'Lista de Sesiones',
                          columns: const [
                            'Id',
                            'Fecha',
                            'Documento',
                            'Periodo',
                          ],
                          data: provider.sesiones,
                          cellBuilders: [
                            (detalle) => Text(detalle.idSesion.toString()),
                            (detalle) => Text(formatearHoraColombiana(detalle.fechaHora)),
                            (detalle) => Text(detalle.documento?.documento ?? 'N/A'),
                            (detalle) => Text(detalle.idPeriodo?.nombrePeriodo?.toString() ?? 'N/A'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}