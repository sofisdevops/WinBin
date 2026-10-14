import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  const ResponsiveLayout({super.key, required this.child});

  int _getSelectedIndex(String location) {
    if (location.startsWith('/ranking')) return 0;
    if (location.startsWith('/perfil')) return 1;
    if (location.startsWith('/admin')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isAdmin, AuthProvider authProvider) {
    if (isAdmin) {
      switch (index) {
        case 0:
          context.go('/ranking');
          break;
        case 1:
          context.go('/perfil');
          break;
        case 2:
          context.go('/admin');
          break;
        case 3:
          authProvider.logout(); 
          context.go('/login');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/ranking');
          break;
        case 1:
          context.go('/perfil');
          break;
        case 2:
          authProvider.logout(); 
          context.go('/login');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isAdmin = authProvider.rol == 'ADMIN';

    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = _getSelectedIndex(location);

    if (currentIndex == 3 && !isAdmin) {
      currentIndex = 0;
    }
    final bottomItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events),
        label: 'Ranking',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];



    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          final bool isExtended = constraints.maxWidth >= 1000;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: isExtended,
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) =>
                      _onItemTapped(index, context, isAdmin, authProvider),
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
                          width: 64,
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
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.emoji_events_outlined),
                      label: Text('Ranking'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.person_outlined),
                      label: Text('Perfil'),
                    ),
                    if (isAdmin)
                      const NavigationRailDestination(
                        icon: Icon(Icons.admin_panel_settings_outlined),
                        selectedIcon: Icon(Icons.admin_panel_settings),
                        label: Text('Admin'),
                      ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.logout, color: Colors.redAccent),
                      label: Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Colors.white10,
                ),
                Expanded(
                  child : child
                  
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex >= bottomItems.length ? 0 : currentIndex,
            onTap: (index) => _onItemTapped(index, context, isAdmin, authProvider),
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