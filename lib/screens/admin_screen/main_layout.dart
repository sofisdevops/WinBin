import 'package:flutter/material.dart';
import 'package:winbin/screens/admin_screen/gestion_puntos_view.dart';
import 'package:winbin/screens/admin_screen/gestion_usuarios_view.dart';
import 'configuracion_reglas_view.dart';
import 'periodos_view.dart';
import 'ranking_filtros_view.dart';
import 'widgets_admin/header_bar.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:winbin/screens/admin_screen/dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    DashboardContent(),
    GestionPuntosView(),
    ConfiguracionReglasView(),
    PeriodosView(),
    RankingView(),
    GestionUsuariosView(),
  ];

  Future<void> _cerrarSesion() async {
    await context.read<AuthProvider>().logout();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: const Color.fromARGB(255, 51, 122, 55),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.recycling,
                        color: Color(0xFF2E7D32),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WinBin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Recycling Management',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildNavItem(0, Icons.dashboard, 'Panel de Control'),
                _buildNavItem(1, Icons.stars, 'Gestión de Puntos'),
                _buildNavItem(2, Icons.rule, 'Configuración de Reglas'),
                _buildNavItem(3, Icons.calendar_today, 'Periodos'),
                _buildNavItem(4, Icons.bar_chart, 'Ranking'),
                _buildNavItem(5, Icons.people, 'Gestión de Usuarios'),
                const Spacer(),
                _buildNavItem(6, Icons.settings, 'Ajustes', isAction: true),
                _buildNavItem(
                  6,
                  Icons.logout,
                  'Logout',
                  isAction: true,
                  onTapCallback: () {
                    _cerrarSesion();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const HeaderBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _views[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    bool isAction = false,
    VoidCallback? onTapCallback,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
          leading: Icon(icon, color: Colors.white),
          title: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            if (!isAction) {
              setState(() {
                _selectedIndex = index;
              });
            }
            onTapCallback?.call();
          },
        ),
      ),
    );
  }
}
