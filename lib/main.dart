import 'package:flutter/material.dart';
import 'package:winbin/Providers/categoriaPuntaje_provider.dart';
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
import 'Providers/periodo_provider.dart';
import 'Providers/session_povider.dart';
import 'Providers/cursos_provider.dart';
import 'Providers/historialRanking.dart';
import 'dart:io';

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
          return authProvider.rol == 'ADMIN' ? '/admin' : '/ranking';
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
          redirect: (context, state) {
            if (authProvider.rol != 'ADMIN') {
              return '/ranking';
            }
          },
          builder: (context, state) {
            final anchoPantalla = MediaQuery.sizeOf(context).width;

            if (anchoPantalla < 800) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/ranking');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const MainLayout();
          },
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => ResponsiveLayout(child: child),
          routes: [
            GoRoute(
              path: '/ranking',
              builder: (context, state) => RankingScreen(),
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate? cert, String host, int port) => true;
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await dotenv.load(fileName: ".env");

  final authProvider = AuthProvider();
  await authProvider.obtenerToken();

  if (authProvider.token != null) {
    try {
      await authProvider.obtenerPerfilUsuario();
    } catch (e) {
      authProvider.logout();
    }
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
        ChangeNotifierProxyProvider<AuthProvider, CursosProvider>(
          create: (context) => CursosProvider(),
          update: (context, authProvider, cursoProvider) {
            return cursoProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SessionProvider>(
          create: (context) => SessionProvider(),
          update: (context, authProvider, sessionProvider) {
            return sessionProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, PeriodoProvider>(
          create: (context) => PeriodoProvider(),
          update: (context, authProvider, periodoProvider) {
            return periodoProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AuditoriaProvider>(
          create: (context) => AuditoriaProvider(),
          update: (context, authProvider, auditoriaProvider) {
            return auditoriaProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, CategoriaPuntajeProvider>(
          create: (context) => CategoriaPuntajeProvider(),
          update: (context, authProvider, CategoriaPuntajeProvider) {
            return CategoriaPuntajeProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, HistorialRankingProvider>(
          create: (context) => HistorialRankingProvider(),
          update: (context, authProvider, historialRankingProvider) {
            return historialRankingProvider!..updateToken(authProvider.token);
          },
        ),
        ChangeNotifierProvider(create: (_) => GestionPuntosProvider()),
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
