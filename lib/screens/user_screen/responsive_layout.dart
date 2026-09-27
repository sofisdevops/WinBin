import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  const ResponsiveLayout({super.key, required this.child});

  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/ranking')) return 1;
    if (location.startsWith('/perfil')) return 2;
    if (location.startsWith('/admin')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/ranking');
        break;
      case 2:
        context.go('/perfil');
        break;
      case 3:
        context.go('/admin');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isAdmin = authProvider.rol == 'ADMIN';

    final String location = GoRouterState.of(context).uri.path;
    final int currentIndex = _getSelectedIndex(location);

    final railItems = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        label: Text('Inicio'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.emoji_events_outlined),
        label: Text('Ranking'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outlined),
        label: Text('Perfil'),
      ),
    ];

    final bottomItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Inicio',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events),
        label: 'Ranking',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ];

    if (isAdmin) {
      railItems.add(
        const NavigationRailDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: Text('Admin'),
        ),
      );
      bottomItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }

    final int safeIndex = currentIndex >= bottomItems.length ? 0 : currentIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          final bool isExtended = constraints.maxWidth >= 1000;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: isExtended,
                  selectedIndex: safeIndex,
                  onDestinationSelected: (index) =>
                      _onItemTapped(index, context),
                  backgroundColor: const Color(0xFF1E1E1E),
                  useIndicator: true,
                  indicatorColor: const Color(
                    0xFF66BB6A,
                  ).withValues(alpha: 0.2),
                  selectedIconTheme: const IconThemeData(
                    color: Color(0xFF66BB6A),
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.white54,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF66BB6A),
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Courier',
                  ),
                  labelType: isExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'lib/assets/images/logo.png',
                          width: 64, // Ajusta el tamaño si es necesario
                        ),
                        if (isExtended) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'WINBIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Courier',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: railItems,
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Colors.white10,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: safeIndex,
            onTap: (index) => _onItemTapped(index, context),
            backgroundColor: const Color(0xFF1E1E1E),
            selectedItemColor: const Color(0xFF66BB6A),
            unselectedItemColor: Colors.white54,
            items: bottomItems,
          ),
        );
      },
    );
  }
}
