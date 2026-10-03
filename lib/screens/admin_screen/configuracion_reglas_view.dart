import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Providers/categoriaPuntaje_provider.dart';

class ConfiguracionReglasView extends StatefulWidget {
  const ConfiguracionReglasView({super.key});

  @override
  State<ConfiguracionReglasView> createState() => _ConfiguracionReglas();
}

class _ConfiguracionReglas extends State<ConfiguracionReglasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoriaPuntajeProvider>(
        context,
        listen: false,
      ).fetchPuntajeCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriaPuntajeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.fetchPuntajeCategorias(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Si la lista está vacía
        if (provider.puntajeCategorias.isEmpty) {
          return const Center(
            child: Text('No hay configuraciones de puntaje disponibles.'),
          );
        }

        final Map<String, List<dynamic>> categoriasAgrupadas = {};

        for (var regla in provider.puntajeCategorias) {
          final nombre = regla.id_material?.nombreMaterial ?? 'Sin Categoría';

          if (!categoriasAgrupadas.containsKey(nombre)) {
            categoriasAgrupadas[nombre] = [];
          }
          categoriasAgrupadas[nombre]!.add(regla);
        }

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
                  children: categoriasAgrupadas.entries.map((categoria) {
                    final String nombreCategoria = categoria.key;
                    final List<dynamic> listaReglas = categoria.value;

                    return _construirTarjetaCategoria(
                      icono: _obtenerIconoCategoria(nombreCategoria),
                      titulo: nombreCategoria,

                      children: listaReglas.map((categoria) {
                        return CampoEntradaRegla(
                          key: ValueKey(
                            '${categoria.id_categoria}_${categoria.tamanno}',
                          ),
                          encabezado: categoria.tamanno.toUpperCase(),
                          valorInicial: categoria.puntos,
                          alCambiar: (nuevoTexto) {
                            final nuevosPuntos = nuevoTexto;
                            if (nuevosPuntos != null) {
                              context
                                  .read<CategoriaPuntajeProvider>()
                                  .registrarCambioPuntaje(
                                    categoria.id_categoria,
                                    nuevosPuntos,
                                  );

                              context
                                  .read<CategoriaPuntajeProvider>()
                                  .actualizarPuntajeLocal(
                                    categoria.id_categoria,
                                    nuevosPuntos,
                                  );
                            }
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 35),
              Center(
                child: _construirBotonGuardar(
                  onPressed: () async {
                    // Llamamos al método de guardado en la base de datos o API
                    final provider = Provider.of<CategoriaPuntajeProvider>(
                      context,
                      listen: false,
                    );

                    final exito = await provider.guardarCambiosPuntajes();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            exito
                                ? '¡Reglas actualizadas correctamente!'
                                : 'Error al actualizar las reglas en el servidor o sin cambios:.',
                          ),
                          backgroundColor: exito
                              ? const Color(0xFF1B5E20)
                              : Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método auxiliar para mapear un icono según el nombre de la categoría
  Widget _obtenerIconoCategoria(String nombre) {
    final nombreMinuscula = nombre.toLowerCase();
    if (nombreMinuscula.contains('botella') ||
        nombreMinuscula.contains('plástico')) {
      return const Icon(Icons.water_drop, color: Color(0xFF2E7D32), size: 34);
    } else if (nombreMinuscula.contains('cartón') ||
        nombreMinuscula.contains('carton')) {
      return const Icon(Icons.inventory_2, color: Color(0xFF2E7D32), size: 34);
    }
    return const Icon(Icons.category, color: Color(0xFF2E7D32), size: 34);
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

  Widget _construirBotonGuardar({required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
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

  Widget _construirTarjetaCategoria({
    required Widget icono,
    required String titulo,
    String? subtitulo,
    required List<Widget> children,
  }) {
    return Container(
      width: 480,
      constraints: const BoxConstraints(minHeight: 280),
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
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitulo ?? '',
                style: const TextStyle(color: Color(0xFF6E6E6E), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
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
  final String? descripcion;
  final ValueChanged<int>? alCambiar;

  const CampoEntradaRegla({
    super.key,
    required this.encabezado,
    required this.valorInicial,
    this.descripcion,
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
  void didUpdateWidget(covariant CampoEntradaRegla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valorInicial != widget.valorInicial) {
      _valor = widget.valorInicial;
      _controlador.text = _valor.toString();
    }
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
              widget.descripcion ?? '',
              style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
