import 'package:flutter/material.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            const Text(
              'Ranking',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Exportar a PDF / Excel'),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar a PDF / Excel'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'semana', label: Text('Semana')),
                ButtonSegment(value: 'mes', label: Text('Mes')),
                ButtonSegment(value: 'periodo', label: Text('Periodo')),
                ButtonSegment(value: 'ano', label: Text('Año')),
              ],
              selected: const {'semana'},
              onSelectionChanged: (set) {},
            ),
          ),

          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis
                      .horizontal, // Habilita el desplazamiento táctil hacia los lados
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('POSICIÓN')),
                      DataColumn(label: Text('CURSO / ESTUDIANTE')),
                      DataColumn(label: Text('TOTAL KG')),
                      DataColumn(label: Text('PUNTOS')),
                    ],
                    rows: const [
                      DataRow(
                        cells: [
                          DataCell(
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.amber,
                              child: Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text('Mateo García (5to Grado A)')),
                          DataCell(Text('345.2 Kg')),
                          DataCell(
                            Text(
                              '5,400 pts',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey,
                              child: Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text('Segundo Grado B')),
                          DataCell(Text('310.8 Kg')),
                          DataCell(
                            Text(
                              '4,920 pts',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
