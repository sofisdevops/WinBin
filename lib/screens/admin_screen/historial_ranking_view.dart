import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/historial_ranking.dart';
import 'package:winbin/Providers/historialRanking.dart';
import 'package:winbin/Providers/periodo_provider.dart';
import 'widgets_admin/tablagenerica.dart';

class HistorialRankingView extends StatefulWidget {
  const HistorialRankingView({super.key});

  @override
  State<HistorialRankingView> createState() => _HistorialRankingViewState();
}

class _HistorialRankingViewState extends State<HistorialRankingView> {
  final Color primaryGreen = const Color(0xFF1B5E20);
  String? _periodoSeleccionadoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistorialRankingProvider>().fetchHistoriales();
      context.read<PeriodoProvider>().fetchPeriodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final periodoProvider = context.watch<PeriodoProvider>();

    return Consumer<HistorialRankingProvider>(
      builder: (context, provider, child) {

        final historialesFiltrados = _periodoSeleccionadoId == null
            ? provider.historiales
            : provider.historiales
                .where((h) => h.id_periodo.toString() == _periodoSeleccionadoId)
                .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial de periodos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text('Seleccionar periodo'),
                        value: _periodoSeleccionadoId,
                        items: periodoProvider.periodos.map((periodo) {
                          return DropdownMenuItem<String>(
                            value: periodo.idPeriodo.toString(),
                            child: Text(periodo.nombrePeriodo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _periodoSeleccionadoId = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Consulta los registros e información guardada por periodo.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.isLoading && provider.historiales.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (historialesFiltrados.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("No hay información guardada para este periodo"),
                        ),
                      )
                    else
                      GenericTable<HistorialRanking>(
                        title: 'Registros del Ranking',
                        columns: const ['Puesto', 'Premio', 'Puntos', 'Documento', 'Fecha'],
                        data: historialesFiltrados,
                        rowsPerPage: 5,
                        cellBuilders: [
                          (h) => Text(
                                h.puesto.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                          (h) => Text(h.tipoPremio),
                          (h) => Text(h.puntosLogrados.toString()),
                          (h) => Text(h.documento.toString()),
                          (h) => Text(h.fecha.toIso8601String().split('T').first),
                        ],
                        onEdit: null,
                        onDelete: null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}