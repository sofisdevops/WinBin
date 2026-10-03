import 'package:flutter/material.dart';
import 'package:winbin/screens/ranking_screen/ranking_screen.dart';
import 'screens/admin_screen/main_layout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/screens/user_screen/responsive_layout.dart';
import 'Providers/UsuarioProvider.dart';
import 'package:provider/provider.dart';
import 'package:winbin/screens/login_screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:winbin/screens/login_screens/register_screen.dart';
import 'Providers/gestion_puntos_provider.dart';
import 'Providers/auditoria_provider.dart';
import 'Providers/dashboard_provider.dart';
import 'package:winbin/screens/user_screen/profile_screen/profile_screen.dart';
import './Providers/ranking_provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouterSetup {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool estaLogueado = authProvider.token != null;
        final bool vaAVistaPublica =
            state.uri.path == '/login' || state.uri.path == '/register';

        if (!estaLogueado && !vaAVistaPublica) {
          return '/login';
        }

        if (estaLogueado && vaAVistaPublica) {
          return authProvider.rol == 'ADMIN' ? '/admin' : '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const MainLayout(),
          redirect: (context, state) {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.rol != 'ADMIN') {
              return '/home';
            }
            return null;
          },
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => ResponsiveLayout(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Vista Home'))),
            ),
            GoRoute(
              path: '/ranking',
              builder: (context, state) =>RankingScreen(),
            ),
            GoRoute(
              path: '/perfil',
              builder: (context, state) => ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authProvider = AuthProvider();
  await authProvider.obtenerToken();
  if (authProvider.token != null) {
    await authProvider.obtenerPerfilUsuario();
  }

  final router = AppRouterSetup.createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, UsuarioProvider>(
          create: (context) => UsuarioProvider(),
          update: (context, authProvider, usuarioProvider) {
            return usuarioProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProvider(create: (_) => GestionPuntosProvider()),
        ChangeNotifierProvider(create: (_) => AuditoriaProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),

      ],
      child: MiAppWeb(router: router),
    ),
  );
}

class MiAppWeb extends StatelessWidget {
  final GoRouter router;
  const MiAppWeb({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'WIN BIN :D',
      theme: ThemeData(fontFamily: 'Courier'),
      routerConfig: router,
    );
  }
}
