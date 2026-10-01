import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfiguracionReglasView extends StatelessWidget {
  const ConfiguracionReglasView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirEncabezado(),
          const SizedBox(height: 30),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 24,
              children: [
                _construirTarjetaBotellas(),
                _construirTarjetaCarton(),
              ],
            ),
          ),
          const SizedBox(height: 35),
          Center(
            child: _construirBotonGuardar(),
          ),
        ],
      ),
    );
  }

  Widget _construirEncabezado() {
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
        SizedBox(height: 4),
        Text(
          'Configuración de Puntos por Categoría y Tamaño',
          style: TextStyle(color: Color(0xFF747474)),
        ),
      ],
    );
  }

  Widget _construirBotonGuardar() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {},
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text(
        'Guardar Cambios de Reglas',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirTarjetaBotellas() {
    return _construirTarjetaCategoria(
      icono: const Icon(Icons.water_drop, color: Color(0xFF2E7D32), size: 34),
      titulo: 'Botella Plástica',
      subtitulo: 'Botellas PED, PEAD y plásticos domésticos',
      children: [
        CampoEntradaRegla(
          encabezado: 'PEQUEÑA',
          valorInicial: 10,
          descripcion: 'Capacidad 500ml',
          alCambiar: (valor) {},
        ),
        CampoEntradaRegla(
          encabezado: 'MEDIANA',
          valorInicial: 20,
          descripcion: 'Cantidad 500ml - 1.5L',
          alCambiar: (valor) {},
        ),
        CampoEntradaRegla(
          encabezado: 'GRANDE',
          valorInicial: 50,
          descripcion: 'Capacidad 5L',
          alCambiar: (valor) {},
        ),
      ],
    );
  }

  Widget _construirTarjetaCarton() {
    return _construirTarjetaCategoria(
      icono: const Icon(Icons.inventory_2, color: Color(0xFF2E7D32), size: 34),
      titulo: 'Carton',
      subtitulo: 'Retazos, pastas de cuaderno, cajas',
      children: [
        CampoEntradaRegla(
          encabezado: 'RETAZO PEQUEÑO',
          valorInicial: 10,
          descripcion: 'Caja pequeña',
          alCambiar: (valor) {},
        ),
        CampoEntradaRegla(
          encabezado: 'RETAZO MEDIANO',
          valorInicial: 20,
          descripcion: 'Caja mediana',
          alCambiar: (valor) {},
        ),
        CampoEntradaRegla(
          encabezado: 'RETAZO GRANDE',
          valorInicial: 50,
          descripcion: 'Caja grande',
          alCambiar: (valor) {},
        ),
      ],
    );
  }

  Widget _construirTarjetaCategoria({
    required Widget icono,
    required String titulo,
    required String subtitulo,
    required List<Widget> children,
  }) {
    return Container(
      width: 480,
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDF7A58), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icono,
                  const SizedBox(width: 12),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitulo,
                style: const TextStyle(color: Color(0xFF6E6E6E), fontSize: 14),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ],
      ),
    );
  }
}

class CampoEntradaRegla extends StatefulWidget {
  final String encabezado;
  final int valorInicial;
  final String descripcion;
  final ValueChanged<int>? alCambiar;

  const CampoEntradaRegla({
    super.key,
    required this.encabezado,
    required this.valorInicial,
    required this.descripcion,
    this.alCambiar,
  });

  @override
  State<CampoEntradaRegla> createState() => _CampoEntradaReglaState();
}

class _CampoEntradaReglaState extends State<CampoEntradaRegla> {
  late TextEditingController _controlador;
  late int _valor;

  @override
  void initState() {
    super.initState();
    _valor = widget.valorInicial;
    _controlador = TextEditingController(text: _valor.toString());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _incrementar() {
    setState(() {
      _valor++;
      _controlador.text = _valor.toString();
    });
    widget.alCambiar?.call(_valor);
  }

  void _decrementar() {
    if (_valor > 0) {
      setState(() {
        _valor--;
        _controlador.text = _valor.toString();
      });
      widget.alCambiar?.call(_valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFECEAE4),
        borderRadius: BorderRadius.circular(12),
      ),
      
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFDC683B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              widget.encabezado,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _controlador,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.1,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          onChanged: (texto) {
                            final parseado = int.tryParse(texto) ?? 0;
                            _valor = parseado;
                            widget.alCambiar?.call(_valor);
                          },
                        ),
                        const Text(
                          'Puntos',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _incrementar,
                        child: const Icon(
                          Icons.keyboard_arrow_up,
                          size: 18,
                          color: Color(0xFFDC683B),
                        ),
                      ),
                      InkWell(
                        onTap: _decrementar,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFFDC683B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 4, right: 4),
            child: Text(
              widget.descripcion,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF555555),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}