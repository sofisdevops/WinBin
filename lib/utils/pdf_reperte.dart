import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart' show rootBundle; 

Future<pw.Document> generarReporteWinbin(
  Map<String, dynamic> data,
  String creador,
  String rol,
  Uint8List imagenGraficoSesiones,
  Uint8List imagenGraficoReciclaje,
) async {
  final pdf = pw.Document();

  final fontNormal = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();
  final fontItalic = await PdfGoogleFonts.robotoItalic();

  final theme = pw.ThemeData.withFont(
    base: fontNormal,
    bold: fontBold,
    italic: fontItalic,
  );

  pw.MemoryImage? logoImage;
  try {
    final logoBytes = await rootBundle.load('lib/assets/images/logo.png');
    logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
  } catch (e) {   
  }

 
  await initializeDateFormatting('es', null); 
  
  final fechaActual = DateFormat("dd 'de' MMMM 'de' yyyy - hh:mm a", 'es').format(DateTime.now());


  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4, // Formato vertical A4 (Documento formal)
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        theme: theme,
      ), // --- PIE DE PÁGINA GLOBAL ---
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount} - Winbin Platform',
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
          ),
        );
      },
      build: (pw.Context context) {
        return [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('REPORTE EJECUTIVO WINBIN', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E7D32))), // Verde oscuro
                  pw.SizedBox(height: 5),
                  pw.Text('Análisis de Rendimiento y Participación', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                ]
              ),
              if (logoImage != null) 
                pw.Image(logoImage, height: 60) 
              else
                pw.SizedBox(height: 60), 
            ],
          ),
          pw.SizedBox(height: 20),
          
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _crearMetadato('Periodo Activo:', data['periodoActivo'] ?? 'Periodo Actual'),
                _crearMetadato('Generado el:', fechaActual),
                _crearMetadato('Preparado por:', '$creador ($rol)'),
              ]
            )
          ),
          pw.SizedBox(height: 30),
          _crearTituloSeccion('1. Resumen Operativo'),
          pw.SizedBox(height: 10),
          pw.Text(
            'El siguiente cuadro presenta las métricas generales de la plataforma durante el periodo evaluado.',
            style: const pw.TextStyle(color: PdfColors.grey800, fontSize: 11),
          ),
          pw.SizedBox(height: 10),
          
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF37474F)),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Métrica', 'Valor Registrado'],
            data: [
              ['Total de Usuarios Registrados', data['totalUsuarios'].toString()],
              ['Usuarios Inactivos', data['usuariosInactivos'].toString()],
              ['Cursos Activos', data['totalCursos'].toString()],
              ['Materiales Reciclables Registrados', data['totalMateriales'].toString()],
              ['Puntos Totales Acumulados', data['puntosTotalesUsuarios'].toString()],
            ],
          ),
          pw.SizedBox(height: 30),
          _crearTituloSeccion('2. Rendimiento Destacado'),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: PdfColor.fromInt(0xFF2E7D32), width: 4)),
              color: PdfColors.green50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _crearFilaDestacada('Estudiante con más puntos:', data['topEstudiante'] ?? 'No disponible'),
                pw.SizedBox(height: 8),
                _crearFilaDestacada('Curso con más puntos:', data['topCurso'] ?? 'No disponible'),
                pw.SizedBox(height: 8),
                _crearFilaDestacada('Usuario con más sesiones:', data['topSesiones'] ?? 'No disponible'),
                pw.SizedBox(height: 8),
                _crearFilaDestacada('Materiales más registrados:', data['topRegistrosIA'] ?? 'No disponible'),
              ]
            ),
          ),
          pw.SizedBox(height: 30),

          _crearTituloSeccion('3. Análisis Gráfico'),
          pw.SizedBox(height: 15),
          
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text('3.1 Comportamiento de Sesiones', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(height: 5),
              pw.Container(
                height: 200,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Image(pw.MemoryImage(imagenGraficoSesiones), fit: pw.BoxFit.contain),
              ),
              
              pw.SizedBox(height: 25),
              
              pw.Text('3.2 Registro de Reciclajes Exitosos', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(height: 5),
              pw.Container(
                height: 200,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Image(pw.MemoryImage(imagenGraficoReciclaje), fit: pw.BoxFit.contain),
              ),
            ]
          )
        ];
      },
    ),
  );

  return pdf;
}


pw.Widget _crearTituloSeccion(String titulo) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 5),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1.5))
    ),
    child: pw.Text(
      titulo,
      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
    ),
  );
}

pw.Widget _crearMetadato(String titulo, String valor) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(titulo, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
      pw.Text(valor, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
    ]
  );
}

pw.Widget _crearFilaDestacada(String titulo, String valor) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 2,
        child: pw.Text(titulo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
      ),
      pw.Expanded(
        flex: 3,
        child: pw.Text(valor, style: const pw.TextStyle(color: PdfColors.black)),
      ),
    ],
  );
}