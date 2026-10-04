import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/auditoria_model.dart';
import 'package:winbin/Providers/auditoria_provider.dart';
import './widgets_admin/tablaGenerica.dart';

class GestionAuditoriaView extends StatefulWidget {
  const GestionAuditoriaView({super.key});

  @override
  State<GestionAuditoriaView> createState() => _GestionAuditoriaViewState();
}

class _GestionAuditoriaViewState extends State<GestionAuditoriaView> {
  String _filtroActual = 'TODAS';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditoriaProvider>().cargarTabla(refresh: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditoriaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTabla) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        if (provider.errorMessageTabla != null) {
          return Center(child: Text('Error: ${provider.errorMessageTabla}'));
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Auditoria',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Administra los logs de las auditorias del sistema.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF2E7D32);
                    }
                    return Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF2E7D32);
                  }),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Color(0xFF2E7D32), width: 1),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                segments: const [
                  ButtonSegment(
                    value: 'TODAS',
                    label: Text('Todas'),
                    icon: Icon(Icons.layers_outlined),
                  ),
                  ButtonSegment(
                    value: 'INSERT',
                    label: Text('Insert'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                  ButtonSegment(
                    value: 'UPDATE',
                    label: Text('Update'),
                    icon: Icon(Icons.edit_outlined),
                  ),
                  ButtonSegment(
                    value: 'DELETE',
                    label: Text('Delete'),
                    icon: Icon(Icons.delete_outline),
                  ),
                ],
                selected: {_filtroActual},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _filtroActual = newSelection.first;
                  });

                  final filtroBackend = _filtroActual == 'TODAS'
                      ? null
                      : _filtroActual;
                  provider.cargarTabla(
                    refresh: true,
                    accionFiltro: filtroBackend,
                  );
                },
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${provider.auditoriasTabla.length} Auditorias encontradas',
                            ),
                            backgroundColor: Color(0xFFC8E6C9),
                          ),
                        ],
                      ),

                      const Divider(height: 30),
                      GenericTable<Auditoria>(
                        title: 'Lista de Auditorias',
                        columns: const [
                          'Id',
                          'Fecha',
                          'Accion',
                          'Tabla Afectada',
                          'Valores Actuales',
                          'Usuario',
                        ],
                        data: provider.auditoriasTabla,
                        cellBuilders: [
                          (auditoria) => Text(auditoria.idAuditoria.toString()),
                          (auditoria) => Text(auditoria.fecha.toString()),
                          (auditoria) => Text(auditoria.accion.toString()),
                          (auditoria) =>
                              Text(auditoria.tablaAfectada.toString()),
                          (auditoria) {
                            final valor = auditoria.valorActual ?? 'N/A';

                            if (valor == 'N/A' || valor.length < 30) {
                              return Text(valor);
                            }
                            return SizedBox(
                              width:
                                  200, 
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Detalle de Valores Actuales',
                                      ),
                                      content: SizedBox(
                                        width: 500, // Ancho máximo del modal
                                        child: SingleChildScrollView(
                                          // SelectableText permite copiar el contenido (ideal para depurar)
                                          child: SelectableText(
                                            valor,
                                            style: const TextStyle(height: 1.5),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        valor,
                                        maxLines: 1, // Limita a una sola línea
                                        overflow: TextOverflow
                                            .ellipsis, // Agrega los "..."
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons
                                          .open_in_new, // Icono para indicar que se puede expandir
                                      size: 16,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          (auditoria) =>
                              Text(auditoria.documento?.documento ?? 'N/A'),
                        ],
                      ),
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
