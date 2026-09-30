import 'package:flutter/material.dart';

import '../profile_screen/widgets_profile/profile_app_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: const ProfileAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final esComputador = constraints.maxWidth >= 700;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: esComputador ? _disenoComputador() : _disenoCelular(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _disenoCelular() {
    return Column(
      children: [
        const RankingHeader(),
        const SizedBox(height: 12),
        const PodiumBanner(),
        const SizedBox(height: 12),
        // Botones de pestañas PERSONAS / CURSOS
        RankingTabs(
          showPersonas: verPersonas,
          onSelectTab: (alSeleccionarPersonas) {
            setState(() {
              verPersonas = alSeleccionarPersonas;
            });
          },
        ),
        const SizedBox(height: 12),
        verPersonas ? _listaPersonas() : _listaCursos(),
      ],
    );
  }

  Widget _disenoComputador() {
    return Column(
      children: [
        const RankingHeader(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 4,
              child: PodiumBanner(),
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
                  verPersonas ? _listaPersonas() : _listaCursos(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _listaPersonas() {
    return const Column(
      children: [
        RankingCard(
          position: 1,
          title: 'ALEX "ECO-WARRIOR" M.',
          subtitle: 'Lvl 42',
          points: 9450,
          borderColor: Color(0xFFFFD700),
          positionColor: Color(0xFFFFD700),
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 2,
          title: 'SAMURAI TRASH',
          subtitle: 'Lvl 39',
          points: 8120,
          borderColor: Color(0xFFC0C0C0),
          positionColor: Color(0xFFC0C0C0),
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 3,
          title: 'GREEN BEAR',
          subtitle: 'Lvl 35',
          points: 7890,
          borderColor: Color(0xFFCD7F32),
          positionColor: Color(0xFFCD7F32),
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 4,
          title: 'RECYCLEDOTOR',
          points: 6500,
          positionColor: Colors.grey,
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 5,
          title: 'TÚ (RANK ACTUAL)',
          points: 1250,
          borderColor: Color(0xFF00FF66),
          positionColor: Color(0xFF00FF66),
        ),
      ],
    );
  }

  Widget _listaCursos() {
    return const Column(
      children: [
        RankingCard(
          position: 1,
          title: '6° BÁSICO A',
          subtitle: '45 Alumnos',
          points: 18450,
          borderColor: Color(0xFFFFD700),
          positionColor: Color(0xFFFFD700),
          icon: Icons.groups,
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 2,
          title: '8° BÁSICO B',
          subtitle: '38 Alumnos',
          points: 14200,
          borderColor: Color(0xFFC0C0C0),
          positionColor: Color(0xFFC0C0C0),
          icon: Icons.groups,
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 3,
          title: '5° BÁSICO C',
          subtitle: '40 Alumnos',
          points: 11890,
          borderColor: Color(0xFFCD7F32),
          positionColor: Color(0xFFCD7F32),
          icon: Icons.groups,
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 4,
          title: '7° BÁSICO A',
          subtitle: '35 Alumnos',
          points: 9500,
          positionColor: Colors.grey,
          icon: Icons.groups,
        ),
        SizedBox(height: 8),
        RankingCard(
          position: 5,
          title: 'TU CURSO (6° A)',
          subtitle: '42 Alumnos',
          points: 8250,
          borderColor: Color(0xFF00FF66),
          positionColor: Color(0xFF00FF66),
          icon: Icons.groups,
        ),
      ],
    );
  }
}