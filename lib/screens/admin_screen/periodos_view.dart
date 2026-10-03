import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/models/perido_model.dart';
import 'package:winbin/Providers/periodo_provider.dart';
import './widgets_admin/tablaGenerica.dart';

class PeriodosView extends StatefulWidget {
  const PeriodosView({super.key});

  @override
  State<PeriodosView> createState() => _PeriodosViewState();
}

class _PeriodosViewState extends State<PeriodosView> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _fechaInicioCtrl = TextEditingController();
  final TextEditingController _fechaFinCtrl = TextEditingController();

  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color accentGreen = const Color(0xFF2E7D32);
  final Color softGreenBg = const Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodoProvider>().fetchPeriodos();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fechaInicioCtrl.dispose();
    _fechaFinCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(
    BuildContext ctx,
    TextEditingController controlador,
  ) async {
    final DateTime? seleccion = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccion != null) {
      final String fechaFormateada =
          "${seleccion.year}-${seleccion.month.toString().padLeft(2, '0')}-${seleccion.day.toString().padLeft(2, '0')}";
      controlador.text = fechaFormateada;

      if (mounted) setState(() {});
    }
  }

  void _crearNuevoPeriodo() async {
    print('nombre: ${_nombreCtrl.text}');
    print('inicio: ${_fechaInicioCtrl.text}');
    print('fin: ${_fechaFinCtrl.text}');
    if (_nombreCtrl.text.isEmpty ||
        _fechaInicioCtrl.text.isEmpty ||
        _fechaFinCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    final nuevoPeriodo = Periodo(
      idPeriodo: '',
      nombrePeriodo: _nombreCtrl.text,
      fechaInicio: _fechaInicioCtrl.text,
      fechaFin: _fechaFinCtrl.text,
      activo: true,
    );

    final exito = await context.read<PeriodoProvider>().crearPeriodo(
      nuevoPeriodo,
    );

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Periodo programado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        _nombreCtrl.clear();
        _fechaInicioCtrl.clear();
        _fechaFinCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al programar el periodo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _mostrarModalEdicion(BuildContext context, Periodo periodo) {
    final TextEditingController edNombreCtrl = TextEditingController(
      text: periodo.nombrePeriodo,
    );
    final TextEditingController edInicioCtrl = TextEditingController(
      text: periodo.fechaInicio,
    );
    final TextEditingController edFinCtrl = TextEditingController(
      text: periodo.fechaFin,
    );
    bool edActivo = periodo.activo;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text(
                'Editar Periodo',
                style: TextStyle(color: Color(0xFF1B5E20)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: edNombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Periodo',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: edInicioCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Inicio',
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
                      onTap: () async {
                        await _seleccionarFecha(ctx, edInicioCtrl);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: edFinCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Fin',
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
                      onTap: () async {
                        await _seleccionarFecha(ctx, edFinCtrl);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Estado Activo'),
                      activeColor: primaryGreen,
                      value: edActivo,
                      onChanged: (val) {
                        setModalState(() {
                          edActivo = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                  ),
                  onPressed: () async {
                    final periodoActualizado = Periodo(
                      idPeriodo: periodo.idPeriodo, // Mantenemos el ID original
                      nombrePeriodo: edNombreCtrl.text,
                      fechaInicio: edInicioCtrl.text,
                      fechaFin: edFinCtrl.text,
                      activo: edActivo,
                    );

                    final exito = await context
                        .read<PeriodoProvider>()
                        .actualizarPeriodo(periodoActualizado);
                    if (exito && mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Periodo actualizado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Consumer<PeriodoProvider>(
      builder: (context, provider, child) {
        final periodoActivo = provider.periodos
            .where((p) => p.activo)
            .firstOrNull;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Periodos de Reciclaje',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Administra los ciclos de competición y establece fechas límite.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 20),

              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 8, color: primaryGreen),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: periodoActivo != null
                              ? (isMobile
                                    ? _buildMobileActivePeriod(periodoActivo)
                                    : _buildDesktopActivePeriod(periodoActivo))
                              : const Center(
                                  child: Text(
                                    'No hay ningún periodo activo actualmente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nuevo Periodo Lectivo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isMobile) ...[
                      _buildInputField(
                        label: 'Fecha de Inicio',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.calendar_month_outlined,
                        controller: _fechaInicioCtrl,
                        onTap: () =>
                            _seleccionarFecha(context, _fechaInicioCtrl),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Fecha de Terminación',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.calendar_month_outlined,
                        controller: _fechaFinCtrl,
                        onTap: () => _seleccionarFecha(context, _fechaFinCtrl),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: 'Fecha de Inicio',
                              hint: 'YYYY-MM-DD',
                              icon: Icons.calendar_month_outlined,
                              controller: _fechaInicioCtrl,
                              onTap: () =>
                                  _seleccionarFecha(context, _fechaInicioCtrl),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              label: 'Fecha de Terminación',
                              hint: 'YYYY-MM-DD',
                              icon: Icons.calendar_month_outlined,
                              controller: _fechaFinCtrl,
                              onTap: () =>
                                  _seleccionarFecha(context, _fechaFinCtrl),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Nombre del Periodo',
                      hint: 'Ej: Trimestre 3 - 2026',
                      controller: _nombreCtrl,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: provider.isLoading
                            ? null
                            : _crearNuevoPeriodo,
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Programar Periodo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
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
                    const Text(
                      'Historial de Periodos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (provider.isLoading && provider.periodos.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.periodos.isEmpty)
                      const Center(child: Text("No hay periodos registrados"))
                    else
                      GenericTable<Periodo>(
                        title: 'Periodos Registrados',
                        columns: const ['Nombre', 'Inicio', 'Fin', 'Estado'],
                        data: provider.periodos,
                        rowsPerPage: 5,
                        cellBuilders: [
                          (p) => Text(
                            p.nombrePeriodo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          (p) => Text(p.fechaInicio),
                          (p) => Text(p.fechaFin),
                          (p) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.activo
                                  ? softGreenBg
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p.activo ? 'ACTIVO' : 'ARCHIVADO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: p.activo ? accentGreen : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                        isRowActive: (p) => p.activo,
                        onEdit: (p) => _mostrarModalEdicion(
                          context,
                          p,
                        ),
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

  Widget _buildDesktopActivePeriod(Periodo periodo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: softGreenBg, shape: BoxShape.circle),
          child: Icon(Icons.autorenew, color: accentGreen, size: 28),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Periodo Activo: ${periodo.nombrePeriodo}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildRichTextDate(periodo.fechaFin),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActivePeriod(Periodo periodo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: softGreenBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.autorenew, color: accentGreen, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periodo Activo: ${periodo.nombrePeriodo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRichTextDate(periodo.fechaFin),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRichTextDate(String fechaFinStr) {
    DateTime? fechaFin = DateTime.tryParse(fechaFinStr);
    int diasRestantes = 0;
    if (fechaFin != null) {
      diasRestantes = fechaFin.difference(DateTime.now()).inDays;
    }
    return Text.rich(
      TextSpan(
        text: 'Finaliza en ',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        children: [
          TextSpan(
            text: diasRestantes >= 0 ? '$diasRestantes días' : 'Vencido',
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' ($fechaFinStr)'),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    IconData? icon,
    required TextEditingController controller,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            suffixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: const Color(0xFFF1F8E9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }  
}