import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/historial_ranking.dart';
import 'package:winbin/Providers/historialRanking.dart';
import 'package:winbin/Providers/periodo_provider.dart';
import 'package:winbin/models/perido_model.dart';
import '../admin_screen/widgets_admin/tablaGenerica.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final periodoProv = context.read<PeriodoProvider>();
      final rankingProv = context.read<HistorialRankingProvider>();

      await periodoProv.fetchPeriodos();
      if (periodoProv.periodos.isNotEmpty) {
        final primerPeriodoId = periodoProv.periodos.first.idPeriodo.toString();
        setState(() {
          _periodoSeleccionadoId = primerPeriodoId;
        });

        rankingProv.fetchHistoriales(primerPeriodoId);
      }
    });
  }

  void _onPeriodoCambiado(String? nuevoId) {
    if (nuevoId == null) return;
    setState(() {
      _periodoSeleccionadoId = nuevoId;
    });

    context.read<HistorialRankingProvider>().fetchHistoriales(nuevoId);
  }

  // Método auxiliar para formatear la fecha
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'N/A';
    return fecha.toIso8601String().split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    final periodoProvider = context.watch<PeriodoProvider>();

    // Buscar el objeto Periodo completo correspondiente al ID seleccionado
    Periodo? periodoSeleccionado;
    if (_periodoSeleccionadoId != null && periodoProvider.periodos.isNotEmpty) {
      try {
        periodoSeleccionado = periodoProvider.periodos.firstWhere(
          (p) => p.idPeriodo.toString() == _periodoSeleccionadoId,
        );
      } catch (_) {
        periodoSeleccionado = null;
      }
    }

    return Consumer<HistorialRankingProvider>(
      builder: (context, provider, child) {
        final todosLosHistoriales = provider.historiales;

        // 1. Filtrar registros individuales y ordenarlos por puesto
        final historialesIndividuales = todosLosHistoriales
            .where((h) => h.tipoPremio.toLowerCase() == 'individual')
            .toList()
          ..sort((a, b) => a.puesto.compareTo(b.puesto));

        // 2. Filtrar registros por curso y ordenarlos por puesto
        final historialesCurso = todosLosHistoriales
            .where((h) => h.tipoPremio.toLowerCase() != 'individual')
            .toList()
          ..sort((a, b) => a.puesto.compareTo(b.puesto));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de periodos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Consulta los registros e información guardada por periodo.',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                        onChanged: _onPeriodoCambiado,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- MOSTRAR FECHAS DEL PERIODO SELECCIONADO ---
              if (periodoSeleccionado != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Fecha Inicio: ${_formatearFecha(DateTime.tryParse(periodoSeleccionado.fechaInicio ?? ""))}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '|',
                        style: TextStyle(color: primaryGreen.withOpacity(0.5)),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.event, size: 18, color: primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Fecha Fin: ${_formatearFecha(DateTime.tryParse(periodoSeleccionado.fechaFin ?? ""))}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (todosLosHistoriales.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      "No hay información guardada para este periodo",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // --- TABLA 1: RANKING INDIVIDUAL ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: historialesIndividuales.isEmpty
                          ? const Center(
                              child: Text('No hay registros individuales en este periodo.'),
                            )
                          : GenericTable<HistorialRanking>(
                              title: 'Ranking Individual',
                              columns: const [
                                'Puesto',
                                'Estudiante',
                                'Documento',
                                'Puntos',
                                'Fecha',
                              ],
                              data: historialesIndividuales,
                              rowsPerPage: 5,
                              cellBuilders: [
                                (h) => Text(
                                      '#${h.puesto}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                (h) => Text(h.documento?.nombre ?? 'Sin Nombre'),
                                (h) => Text(h.documento?.documento ?? 'Sin Documento'),
                                (h) => Text(
                                      h.puntosLogrados.toString(),
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                (h) => Text(
                                      h.fecha.toIso8601String().split('T').first,
                                    ),
                              ],
                              onEdit: null,
                              onDelete: null,
                            ),
                    ),

                    const SizedBox(height: 24),

                    // --- TABLA 2: RANKING POR CURSO ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: historialesCurso.isEmpty
                          ? const Center(
                              child: Text('No hay registros de cursos en este periodo.'),
                            )
                          : GenericTable<HistorialRanking>(
                              title: 'Ranking por Cursos',
                              columns: const [
                                'Puesto',
                                'Curso',
                                'Puntos',
                                'Fecha',
                              ],
                              data: historialesCurso,
                              rowsPerPage: 5,
                              cellBuilders: [
                                (h) => Text(
                                      '#${h.puesto}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                (h) => Text(
                                      h.id_curso?.nombre ?? ''
                                    ),
                                (h) => Text(
                                      h.puntosLogrados.toString(),
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                (h) => Text(
                                      h.fecha.toIso8601String().split('T').first,
                                    ),
                              ],
                              onEdit: null,
                              onDelete: null,
                            ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}