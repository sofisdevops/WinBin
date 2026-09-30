import 'package:flutter/material.dart';

class PeriodosView extends StatelessWidget {
  const PeriodosView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);
    const accentGreen = Color(0xFF2E7D32);
    const softGreenBg = Color(0xFFE8F5E9);

    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y Subtítulo
          const Text(
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
                  // Línea verde lateral
                  Container(
                    width: 8,
                    color: primaryGreen,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: isMobile 
                          ? _buildMobileActivePeriod(primaryGreen, accentGreen, softGreenBg)
                          : _buildDesktopActivePeriod(primaryGreen, accentGreen, softGreenBg),
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
                const Row(
                  children: [
                    Icon(Icons.calendar_today, color: primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Nuevo Periodo Lectivo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Responsividad de los inputs de fechas
                if (isMobile) ...[
                  _buildInputField(
                    label: 'Fecha de Inicio',
                    hint: '05/12/2026',
                    icon: Icons.calendar_month_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Fecha de Terminación',
                    hint: '08/30/2026',
                    icon: Icons.calendar_month_outlined,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Fecha de Inicio',
                          hint: '05/12/2026',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          label: 'Fecha de Terminación',
                          hint: '08/30/2026',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                _buildInputField(
                  label: 'Nombre del Periodo',
                  hint: 'Ej: Trimestre 3 - 2026',
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
                    onPressed: () {},
                    child: const Text(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historial de Periodos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        isMobile ? 'Ver reporte' : 'Ver reporte completo',
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 650),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: softGreenBg),
                          children: [
                            _buildTableHeader('Periodo'),
                            _buildTableHeader('Inicio'),
                            _buildTableHeader('Fin'),
                            _buildTableHeader('Total Reciclado'),
                            _buildTableHeader('Estado'),
                          ],
                        ),
                        _buildTableRow(
                          'Trimestre 3 – 2026',
                          'Jun 15, 2026',
                          'Sep 31, 2026',
                          '45,800 kg',
                          'ACTUAL',
                        ),
                        _buildTableRow(
                          'Trimestre 2 – 2026',
                          'Mar 31, 2026',
                          'Jun 15, 2026',
                          '45,800 kg',
                          'ARCHIVADO',
                        ),
                        _buildTableRow(
                          'Trimestre 1 – 2026',
                          'Ene 26, 2026',
                          'Mar 30, 2026',
                          '12,450 kg',
                          'ARCHIVADO',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActivePeriod(Color primaryGreen, Color accentGreen, Color softGreenBg) {
    return Row(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Periodo Activo: Trimestre 3',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              _buildRichTextDate(primaryGreen),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 10,
                  backgroundColor: Color(0xFFC8E6C9),
                  color: Color(0xFF66BB6A),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '85% Completado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileActivePeriod(Color primaryGreen, Color accentGreen, Color softGreenBg) {
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
                  const Text(
                    'Periodo Activo: Trimestre 3',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _buildRichTextDate(primaryGreen),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 10,
              backgroundColor: Color(0xFFC8E6C9),
              color: Color(0xFF66BB6A),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '85% Completado',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRichTextDate(Color primaryGreen) {
    return Text.rich(
      TextSpan(
        text: 'Finaliza en ',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        children: [
          TextSpan(
            text: '12 días',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: ' (Miercoles, 31 de Septiembre)',
          ),
        ],
      ),
    );
  }

  static Widget _buildInputField({
    required String label,
    required String hint,
    IconData? icon,
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

  static Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  static TableRow _buildTableRow(
    String periodo,
    String inicio,
    String fin,
    String total,
    String estado,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            periodo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            inicio,
            style: const TextStyle(color: Color(0xFF393939), fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            fin,
            style: const TextStyle(color: Color(0xFF393939), fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            total,
            style: const TextStyle(color: Color(0xFF393939), fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              estado,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}