import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/gestion_puntos_provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/Providers/registroIA_provider.dart';
import 'package:winbin/models/registroIA_model.dart';
import 'package:winbin/models/users_model.dart';
import 'package:winbin/screens/admin_screen/widgets_admin/tablaGenerica.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GestionRegistroia extends StatefulWidget {
  const GestionRegistroia({super.key});

  @override
  State<GestionRegistroia> createState() => _GestionRegistrosIa();
}

class _GestionRegistrosIa extends State<GestionRegistroia> {
  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistroiaProvider>().fetchUsuarios(token);
    });
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final provider = context.read<RegistroiaProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.seletedFecha ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        provider.seletedFecha = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gestionProvider = context.watch<RegistroiaProvider>();
    final authProvider = context.read<AuthProvider>();

    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 20,
      ), // Padding inferior para que no quede pegado al final
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildHeaderTitles(),
            const SizedBox(height: 16),
            _buildTotalRegistrosChip(gestionProvider),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderTitles(),
                _buildTotalRegistrosChip(gestionProvider),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // SECCIÓN DE BÚSQUEDA
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buscar Registro',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.NombreMaterialController,
                            'Nombre del Material',
                            'Nombre del Material...',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            width: 220,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarFecha(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFF2E7D32),
                              ),
                              label: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      gestionProvider.seletedFecha == null
                                          ? 'Seleccionar Fecha'
                                          : '${gestionProvider.seletedFecha!.day}/${gestionProvider.seletedFecha!.month}/${gestionProvider.seletedFecha!.year}',
                                      style: TextStyle(
                                        color:
                                            gestionProvider.seletedFecha == null
                                            ? Colors.black54
                                            : Colors.black87,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (gestionProvider.seletedFecha != null)
                                    InkWell(
                                      onTap: () => setState(
                                        () =>
                                            gestionProvider.seletedFecha = null,
                                      ),
                                      child: const Icon(
                                        Icons.clear,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.confianzaController,
                            'Confianza IA',
                            'Confianza de la IA...',
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSearchButton(
                          gestionProvider,
                          authProvider,
                          "Buscar",
                          Icons.search,
                          ()=>gestionProvider.buscarRegistro(authProvider.token)
                        ),
                        const SizedBox(height: 5),
                        _buildSearchButton(
                          gestionProvider,
                          authProvider,
                          "Limpiar",
                          Icons.cleaning_services_outlined,
                          ()=>gestionProvider.limpiarBusqueda()
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.NombreMaterialController,
                            'Nombre del Material',
                            'Nombre del Material...',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            width: 220,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarFecha(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFF2E7D32),
                              ),
                              label: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      gestionProvider.seletedFecha == null
                                          ? 'Seleccionar Fecha'
                                          : '${gestionProvider.seletedFecha!.day}/${gestionProvider.seletedFecha!.month}/${gestionProvider.seletedFecha!.year}',
                                      style: TextStyle(
                                        color:
                                            gestionProvider.seletedFecha == null
                                            ? Colors.black54
                                            : Colors.black87,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (gestionProvider.seletedFecha != null)
                                    InkWell(
                                      onTap: () => setState(
                                        () =>
                                            gestionProvider.seletedFecha = null,
                                      ),
                                      child: const Icon(
                                        Icons.clear,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            gestionProvider.confianzaController,
                            'Confianza IA',
                            'Confianza de la IA...',
                          ),
                        ),
                        const SizedBox(width: 15),
                        _buildSearchButton(
                          gestionProvider,
                          authProvider,
                          "Buscar",
                          Icons.search,
                          ()=>gestionProvider.buscarRegistro(authProvider.token),
                        ),
                        const SizedBox(width: 5),
                        _buildSearchButton(
                          gestionProvider,
                          authProvider,
                          "Limpiar",
                          Icons.cleaning_services_outlined,
                          ()=>gestionProvider.limpiarBusqueda()
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN DE RESULTADOS
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alineación para móviles
                children: [
                  if (isMobile) ...[
                    const Text(
                      'Resultados de Búsqueda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                   
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Resultados de Búsqueda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       
                      ],
                    ),
                  ],

                  const Divider(height: 30),

                  // Si está cargando muestra el indicador, sino la tabla generica
                  gestionProvider.cargando
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        )
                      : GenericTable<RegistroiaModel>(
                          title: 'Lista de Registros IA',
                          rowsPerPage: 5,
                          columns: const [
                            'IDIA',
                            'CONFIANZA',
                            'IMAGEN',
                            'ID_SESSION',
                            'MATERIAL',
                            'CATEGORIA',
                            'FECHA',
                            'USUARIO',
                          ],
                          data:
                              (gestionProvider
                                      .NombreMaterialController
                                      .text
                                      .isEmpty &&
                                  gestionProvider.seletedFecha == null &&
                                  gestionProvider
                                      .confianzaController
                                      .text
                                      .isEmpty)
                              ? gestionProvider.todosLosRegistris
                              : gestionProvider.registrosEncontrados,
                          cellBuilders: [
                            (estudiante) => Text(
                              estudiante.idIa.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            (estudiante) => Text(
                              "${(estudiante.confianza! * 100).toStringAsFixed(1)}%",
                            ),
                            (estudiante) => ClipRRect(
                              borderRadius: BorderRadius.circular(
                                20,
                              ), // Formato circular/avatar
                              child: CachedNetworkImage(
                                imageUrl: estudiante.utlImagen ?? '',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.account_circle,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),

                            (estudiante) =>
                                Text(estudiante.session?.idSesion ?? 'N/A'),
                            (estudiante) => Text(
                              estudiante.material?.nombreMaterial ?? 'N/A',
                            ),
                            (estudiante) => Text(
                              estudiante.categoria?.tamanno ?? 'N/A'
                            ),
                            (estudiante) => Text(
                              estudiante.session?.fechaHora.toString() ?? 'N/A',
                            ),
                            (estudiante) =>
                                Text(estudiante.session!.documento.nombre),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Registro de Ia',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRegistrosChip(RegistroiaProvider provider) {
    return Chip(
      label: Text(
        'Total de Registros: ${provider.todosLosRegistris.length}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF1B5E20),
    );
  }


  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ), // Ajuste visual de altura
      ),
    );
  }

  Widget _buildSearchButton(
    RegistroiaProvider gestionProvider,
    AuthProvider authProvider,
    String textoBut,
    IconData icono,
    Future<void> Function() onpressedAction,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD06E4B),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onpressedAction,
      icon: Icon(icono, color: Colors.white),
      label: Text(
        textoBut,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
