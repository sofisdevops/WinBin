import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

class Tablagenerica<T> extends DataTableSource {
  final List<T> data;
  final List<Widget Function(T item)> cellBuilders;
  final Function(T item)? onEdit;
  final Function(T item)? onDelete;

  Tablagenerica({
    required this.data,
    required this.cellBuilders,
    this.onEdit,
    this.onDelete,
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
                  onPressed: () => onEdit!(item),
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete!(item),
                ),
            ],
          ),
        ),
      );
    }
    return DataRow(cells: cells);
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

  const GenericTable({
    super.key,
    required this.title,
    required this.columns,
    required this.data,
    required this.cellBuilders,
    this.onEdit,
    this.onDelete,
    this.rowsPerPage = 5,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null;

    final allColumns = [...columns, if (hasActions) 'Acciones'];

    final source = Tablagenerica<T>(
      data: data,
      cellBuilders: cellBuilders,
      onEdit: onEdit,
      onDelete: onDelete,
    );

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
          width: MediaQuery.of(context).size.width > 900
              ? MediaQuery.of(context).size.width - 320
              : 800,
          height: 650,
          child: PaginatedDataTable(
            header: Text(title),
            rowsPerPage: rowsPerPage,
            columns: allColumns
                .map((col) => DataColumn(label: Text(col)))
                .toList(),
            source: source,
          ),
        ),
      ),
    );
  }
}
