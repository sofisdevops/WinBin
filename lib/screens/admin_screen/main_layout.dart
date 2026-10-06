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
import 'package:winbin/screens/admin_screen/gestion_auditoria_view.dart';
import 'package:winbin/screens/admin_screen/gestion_sessione_view.dart';
import 'package:winbin/screens/admin_screen/gestion_cursoso_view.dart';
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    DashboardContent(),
    GestionAuditoriaView(),
    GestionPuntosView(),
    ConfiguracionReglasView(),
    PeriodosView(),
    RankingView(),
    GestionUsuariosView(),
    GestionSessionView(),
    GestionCursoView(),
  ];

  Future<void> _cerrarSesion() async {
    await context.read<AuthProvider>().logout();

    if (mounted) {
      context.go('/login');
    }
  }
   Future<void> _home() async {
      context.go('/home');
 
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      drawer: isMobile ? Drawer(child: _buildSidebar(context, isMobile)) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, isMobile),
          
          Expanded(
            child: Column(
              children: [
                if (isMobile)
                  Container(
                    color: const Color(0xFFF7EFD8), // Mismo color de fondo que tu HeaderBar
                    child: Row(
                      children: [
                        Builder(
                          builder: (ctx) => IconButton(
                            padding: const EdgeInsets.only(left: 16),
                            icon: const Icon(Icons.menu, color: Color(0xFF2E7D32)),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        ),
                        const Expanded(child: HeaderBar()),
                      ],
                    ),
                  )
                else
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

  
  Widget _buildSidebar(BuildContext context, bool isMobile) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 51, 122, 55),
      child: Column(
        children: [
          const SizedBox(height: 40),
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(context, isMobile, 0, Icons.dashboard, 'Panel de Control'),
                _buildNavItem(context, isMobile, 1, Icons.library_books, 'Auditoria'),
                _buildNavItem(context, isMobile, 2, Icons.stars, 'Gestión de Puntos'),
                _buildNavItem(context, isMobile, 3, Icons.rule, 'Configuración de Reglas'),
                _buildNavItem(context, isMobile, 4, Icons.calendar_today, 'Periodos'),
                _buildNavItem(context, isMobile, 5, Icons.bar_chart, 'Ranking'),
                _buildNavItem(context, isMobile, 6, Icons.people, 'Gestión de Usuarios'),
                _buildNavItem(context, isMobile, 7, Icons.person_outline, 'Gestión de Sesiones'),
                _buildNavItem(context, isMobile, 8, Icons.school, 'Gestión de Cursos')
              ],
            ),
          ),
          const Divider(color: Colors.white30, indent: 20, endIndent: 20),
          _buildNavItem(
            context,
            isMobile,
            6,
            Icons.supervised_user_circle,
            'Aplicacion Usuario ',
            isAction: true,
            onTapCallback: () {
              _home();
             
            },
          ),
          _buildNavItem(
            context,
            isMobile,
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
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    bool isMobile,
    int index,
    IconData icon,
    String label, {
    bool isAction = false,
    VoidCallback? onTapCallback,
  }) {
    final isSelected = _selectedIndex == index && !isAction;
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
              if (isMobile) {
                Navigator.of(context).pop();
              }
            }
            onTapCallback?.call();
          },
        ),
      ),
    );
  }
}