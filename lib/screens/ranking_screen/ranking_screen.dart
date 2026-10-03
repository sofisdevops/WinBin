import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/ranking_provider.dart'; 
import '../../Providers/AuthProvider.dart';
import '../user_screen/profile_screen/widgets_profile/profile_app_bar.dart';
import 'widgets_ranking/ranking_header.dart';
import 'widgets_ranking/podium_banner.dart';
import 'widgets_ranking/ranking_tabs.dart';
import 'widgets_ranking/ranking_card.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  bool verPersonas = true;
  int _paginaPersonas = 0; 
  int _paginaCursos = 0;
  final int _itemsPorPagina = 10;

  @override
  void initState() {
    super.initState();
   
     WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token ?? '';
      final provider = context.read<RankingProvider>();
      
      provider.conectar(token); 
      
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: const ProfileAppBar(),
      body: Consumer<RankingProvider>(
        builder: (context, rankingProvider, child) {

          final List<dynamic> listaWS = verPersonas 
              ? rankingProvider.topEstudiantes 
              : rankingProvider.topCursos;
          final List<dynamic> top3 = listaWS.take(3).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final esComputador = constraints.maxWidth >= 700;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: esComputador 
                        ? _disenoComputador(top3, listaWS, rankingProvider) 
                        : _disenoCelular(top3, listaWS, rankingProvider),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _disenoCelular(List<dynamic> top3, List<dynamic> listaWS, RankingProvider provider) {
    return Column(
      children: [
        const RankingHeader(),
        const SizedBox(height: 12),
        PodiumBanner(topUsers: top3, isPersonas: verPersonas), 
        const SizedBox(height: 12),
        RankingTabs(
          showPersonas: verPersonas,
          onSelectTab: (alSeleccionarPersonas) {
            setState(() {
              verPersonas = alSeleccionarPersonas;
            });
          },
        ),
        const SizedBox(height: 12),
        _listaPaginadaDinamica(provider, listaWS), 
      ],
    );
  }

  Widget _disenoComputador(List<dynamic> top3, List<dynamic> listaWS, RankingProvider provider) {
    return Column(
      children: [
        const RankingHeader(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: PodiumBanner(topUsers: top3, isPersonas: verPersonas), 
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  RankingTabs(
                    showPersonas: verPersonas,
                    onSelectTab: (alSeleccionarPersonas) {
                      setState(() {
                        verPersonas = alSeleccionarPersonas;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _listaPaginadaDinamica(provider, listaWS), 
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _listaPaginadaDinamica(RankingProvider provider, List<dynamic> listaWS) {
    final itemsPaginados = verPersonas ? provider.usuarios : provider.cursosPaginados;
    final isLoading = verPersonas ? provider.isLoading : provider.isLoadingCursos;
    final hasMoreData = verPersonas ? provider.hasMoreData : provider.hasMoreDataCursos;
    int paginaActual = verPersonas ? _paginaPersonas : _paginaCursos;
    final listaRestoWS = listaWS.length > 3 ? listaWS.skip(3).toList() : [];

    final Set<String> nombresTop10 = listaWS.map((e) {
      if (e is Map) return (verPersonas ? e['nombre'] : e['nombreCurso']).toString();
      dynamic obj = e;
      return (verPersonas ? obj.nombre : obj.nombreCurso).toString();
    }).toSet();

    final itemsPaginadosFiltrados = itemsPaginados.where((item) {
      String nombreItem;
      if (item is Map) nombreItem = (verPersonas ? item['nombre'] : item['nombreCurso']).toString();
      else {
        dynamic obj = item;
        nombreItem = (verPersonas ? obj.nombre : obj.nombreCurso).toString();
      }
      return !nombresTop10.contains(nombreItem);
    }).toList();

    List<dynamic> itemsPagina = [];
    int posicionInicialReal = 4;

    if (paginaActual == 0) {
      
      itemsPagina = listaRestoWS;
      posicionInicialReal = 4;
    } else {
      int startIndex = (paginaActual - 1) * _itemsPorPagina;
      if (startIndex < itemsPaginadosFiltrados.length) {
        itemsPagina = itemsPaginadosFiltrados.skip(startIndex).take(_itemsPorPagina).toList();
      }

      posicionInicialReal = 11 + startIndex;
    }

    bool canGoBack = paginaActual > 0;
    
    bool canGoNext = false;
    if (paginaActual == 0) {
      canGoNext = (listaWS.length == 10) && (itemsPaginadosFiltrados.isNotEmpty || hasMoreData);
    } else {
      int elementosMostradosHastaAhora = _itemsPorPagina * paginaActual;
      bool hayMasEnMemoria = elementosMostradosHastaAhora < itemsPaginadosFiltrados.length;
      canGoNext = hayMasEnMemoria || hasMoreData;
    }

    // Pantalla de carga si está pidiendo datos
    if (itemsPagina.isEmpty && isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: CircularProgressIndicator(color: Color(0xFF00FF66)),
      );
    }

    // 6. Generar las Cartas con su posición real exacta
    List<Widget> cartas = itemsPagina.asMap().entries.map((entry) {
      int index = entry.key;
      var data = entry.value; 
      
      int posicionReal = posicionInicialReal + index; 

      String titulo;
      int puntos;
      String? avatar;

      if (data is Map) {
        titulo = verPersonas ? (data['nombre'] ?? 'Sin Nombre') : (data['nombreCurso'] ?? 'Curso N/A');
        puntos = verPersonas ? (data['puntos'] ?? 0) : (data['puntosTotales'] ?? 0);
        avatar = verPersonas ? data['avatarUrl'] : null;
      } else {
        dynamic obj = data; 
        titulo = verPersonas ? obj.nombre : obj.nombreCurso;
        puntos = verPersonas ? obj.puntos : obj.puntosTotales;
        avatar = verPersonas ? obj.avatarUrl : null;
      }

      String subtitulo = verPersonas ? '' : 'Curso'; 
      IconData icono = verPersonas ? Icons.account_box : Icons.groups;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RankingCard(
          position: posicionReal,
          title: titulo,
          subtitle: subtitulo,
          avatarUrl: avatar,
          points: puntos,
          positionColor: Colors.grey, 
          icon: icono,
        ),
      );
    }).toList();

    return Column(
      children: [
        ...cartas,
        
        if (itemsPagina.isEmpty && !isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'FIN DEL RANKING',
              style: TextStyle(color: Colors.grey, fontFamily: 'Courier', fontSize: 12),
            ),
          ),

        const SizedBox(height: 12),
        
        // ============================================
        // BARRA DE NAVEGACIÓN (PAGINACIÓN RETRO)
        // ============================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            border: Border.all(color: const Color(0xFF2B2B2B)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BOTÓN ANTERIOR
              TextButton(
                onPressed: canGoBack ? () {
                  setState(() {
                    if (verPersonas) _paginaPersonas--; else _paginaCursos--;
                  });
                } : null,
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 12, color: canGoBack ? const Color(0xFF00FF66) : Colors.grey.withOpacity(0.3)),
                    const SizedBox(width: 4),
                    Text('ANT', style: TextStyle(color: canGoBack ? const Color(0xFF00FF66) : Colors.grey.withOpacity(0.3), fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              // INDICADOR DE PÁGINA
              Text(
                'PÁG ${paginaActual + 1}',
                style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold),
              ),
              
              // BOTÓN SIGUIENTE
              TextButton(
                onPressed: canGoNext ? () {
                  // Si no hay suficientes datos en memoria pero el servidor tiene más, los pedimos
                  int startIndexSiguiente = (paginaActual) * _itemsPorPagina;
                  bool hayDatosEnMemoria = startIndexSiguiente < itemsPaginadosFiltrados.length;

                  setState(() {
                    if (verPersonas) _paginaPersonas++; else _paginaCursos++;
                  });

                  if (!hayDatosEnMemoria && hasMoreData) {
                    final token = context.read<AuthProvider>().token ?? '';
                    if (verPersonas) {
                      provider.fetchRanking(token);
                    } else {
                      provider.fetchRankingCursos(token);
                    }
                  }
                } : null,
                child: Row(
                  children: [
                    Text('SIG', style: TextStyle(color: canGoNext ? const Color(0xFF00FF66) : Colors.grey.withOpacity(0.3), fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: canGoNext ? const Color(0xFF00FF66) : Colors.grey.withOpacity(0.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}