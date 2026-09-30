import 'package:flutter/material.dart';

class ConfiguracionReglasView extends StatelessWidget {
  const ConfiguracionReglasView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildHeaderTitles(),
            const SizedBox(height: 16),
            _buildSaveButton(),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildHeaderTitles(), _buildSaveButton()],
            ),
          ],

          const SizedBox(height: 25),

          if (isMobile) ...[
            _buildBotellasCard(),
            const SizedBox(height: 20),
            _buildCartonCard(),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [_buildBotellasCard(), _buildCartonCard()],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de Reglas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        Text(
          'Configuración de Puntos por Categoría y Tamaño',
          style: TextStyle(color: Color(0xFF747474)),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onPressed: () {},
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text(
        'Guardar Cambios de Reglas',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBotellasCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, color: Color(0xFF2E7D32), size: 30),
                SizedBox(width: 10),
                Text(
                  'Botella Plástica',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Botellas PED, PEAD y plásticos domésticos',
              style: TextStyle(color: Color(0xFF747474)),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildRuleInput('PEQUEÑA', '10', 'Capacidad 500ml'),
                _buildRuleInput('MEDIANA', '20', 'Cantidad 500ml - 1.5L'),
                _buildRuleInput('GRANDE', '50', 'Capacidad 5L'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartonCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2, color: Color(0xFF2E7D32), size: 30),
                SizedBox(width: 10),
                Text(
                  'Carton',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Retazos, pastas de cuaderno, cajas',
              style: TextStyle(color: Color(0xFF747474)),
            ),
            const SizedBox(height: 15),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildRuleInput('RETAZO PEQUEÑO', '10', 'Caja pequeña'),
                _buildRuleInput('RETAZO MEDIANO', '20', 'Caja mediana'),
                _buildRuleInput('RETAZO GRANDE', '50', 'Caja grande'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleInput(String title, String defaultValue, String subtitle) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: defaultValue,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
