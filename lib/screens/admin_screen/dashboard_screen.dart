import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:winbin/Providers/dashboard_provider.dart';
import 'widgets_admin/dashboard/stat_card.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      Provider.of<DashboardProvider>(context, listen: false).cargarResumen(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  int columnas = constraints.maxWidth < 650 ? 1 : (constraints.maxWidth < 1100 ? 3 : 5);
                  double spacing = 16.0;
                  double cardWidth = (constraints.maxWidth - (spacing * (columnas - 1))) / columnas - 0.1;
                  
                  return Wrap(
                    spacing: spacing, 
                    runSpacing: spacing, 
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(title: 'Usuarios', value: provider.totalUsuarios, icon: Icons.people, color: Colors.blue)
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(title: 'Inactivos', value: provider.usuariosInactivos, icon: Icons.person_off, color: Colors.red)
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(title: 'Cursos', value: provider.totalCursos, icon: Icons.school, color: Colors.purple)
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(title: 'Materiales', value: provider.totalMateriales, icon: Icons.category, color: Colors.teal)
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(title: 'Puntos Totales', value: provider.totalPuntos, icon: Icons.stars, color: Colors.amber[700]!)
                      ),
                    ],
                  );
                }
              ),
              
              const SizedBox(height: 32),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1100) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildChartContainer('Sesiones (Por Día)', provider.sesionesSpots, provider.fechasSesiones, Colors.blue),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildChartContainer('Reciclajes Exitosos (Por Día)', provider.reciclajeSpots, provider.fechasReciclaje, const Color(0xFF2E7D32)),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildChartContainer('Sesiones (Por Día)', provider.sesionesSpots, provider.fechasSesiones, Colors.blue),
                      const SizedBox(height: 24),
                      _buildChartContainer('Reciclajes Exitosos (Por Día)', provider.reciclajeSpots, provider.fechasReciclaje, const Color(0xFF2E7D32)),
                    ],
                  );
                }
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartContainer(String title, List<FlSpot> spots, List<String> fechas, Color color) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: RepaintBoundary(
              child: spots.isEmpty 
                  ? const Center(child: Text("Sin actividad reciente", style: TextStyle(color: Colors.grey)))
                  : LineChart(
                      LineChartData(
                        lineTouchData : LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpots) => const Color(0xFF37474F),
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  '${spot.y.toInt()}',
                                  const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < fechas.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(fechas[index], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: color,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}