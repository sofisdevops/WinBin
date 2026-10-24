import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:math' as math;

class Tablagenerica<T> extends DataTableSource {
  final List<T> data;
  final List<Widget Function(T item)> cellBuilders;
  final Function(T item)? onEdit;
  final Function(T item)? onDelete;
  final Function(T item)? active;
  final Function(T item)? desactive;
  final Function(T item)? cambiarRol;
  final bool Function(T item)? isRowActive;

  Tablagenerica({
    required this.data,
    required this.cellBuilders,
    this.onEdit,
    this.onDelete,
    this.active,
    this.desactive,
    this.cambiarRol,
    this.isRowActive,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    // Construir celdas de datos principales
    final cells = cellBuilders
        .map((builder) => DataCell(builder(item)))
        .toList();

    // Agregar columna de acciones si existe al menos una función definida
    if (onEdit != null || onDelete != null) {
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: "editar",
                  onPressed: () => onEdit!(item),
                ),
              if (isRowActive != null) ...[
                if (isRowActive!(item)) ...[
                  if (desactive != null)
                    IconButton(
                      icon: const Icon(
                        Icons.bedtime_off_outlined,
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                      tooltip: 'Desactivar',
                      onPressed: () => desactive!(item),
                    ),
                ] else ...[
                  if (active != null)
                    IconButton(
                      icon: const Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.green,
                      ),
                      tooltip: 'Activar',
                      onPressed: () => active!(item),
                    ),
                ],
              ],

              if (cambiarRol != null)
                IconButton(
                  icon: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.orangeAccent,
                  ),
                  tooltip: 'Cambiar Rol',
                  onPressed: () => cambiarRol!(item),
                ),

              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar',
                  onPressed: () => onDelete!(item),
                ),
            ],
          ),
        ),
      );
    }

    final esPar = index % 2 == 0;
    final colorFondo = esPar
        ? const Color(0xFFF4F4F3)
        : const Color(0xFFEDECE8);

    return DataRow(color: WidgetStateProperty.all(colorFondo), cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

class GenericTable<T> extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<T> data;
  final List<Widget Function(T item)> cellBuilders;
  final Function(T item)? onEdit;
  final Function(T item)? onDelete;
  final int rowsPerPage;
  final Function(T item)? active;
  final Function(T item)? desactive;
  final Function(T item)? cambiarRol;
  final bool Function(T item)? isRowActive;

  final double minWidth;

  const GenericTable({
    super.key,
    required this.title,
    required this.columns,
    required this.data,
    required this.cellBuilders,
    this.onEdit,
    this.onDelete,
    this.rowsPerPage = 5,
    this.active,
    this.desactive,
    this.cambiarRol,
    this.isRowActive,
    this.minWidth = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null;
    final allColumns = [...columns, if (hasActions) 'Acciones'];

    final int effectiveRowsPerPage = data.isEmpty
        ? 1
        : (data.length < rowsPerPage ? data.length : rowsPerPage);

    final source = Tablagenerica<T>(
      data: data,
      cellBuilders: cellBuilders,
      onEdit: onEdit,
      onDelete: onDelete,
      active: active,
      desactive: desactive,
      cambiarRol: cambiarRol,
      isRowActive: isRowActive,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth = constraints.hasBoundedWidth
            ? math.max(constraints.maxWidth, minWidth)
            : minWidth;

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: PaginatedDataTable(
                header: Text(title),
                rowsPerPage: effectiveRowsPerPage,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFD06E4B),
                ),
                columns: allColumns
                    .map(
                      (col) => DataColumn(
                        label: Text(
                          col,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                source: source,
              ),
            ),
          ),
        );
      },
    );
  }
}