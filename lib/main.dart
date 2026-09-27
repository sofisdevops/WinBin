import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:winbin/screens/user_screen/responsive_layout.dart';
import 'Providers/UsuarioProvider.dart';
import 'package:provider/provider.dart';
import 'package:winbin/screens/login_screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:winbin/screens/admin_screen/main_layout.dart';
import 'package:winbin/screens/login_screens/register_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
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
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ResponsiveLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Vista Home'))),
        ),
        GoRoute(
          path: '/ranking',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Vista Ranking'))),
        ),
        GoRoute(
          path: '/perfil',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Vista Perfil'))),
        ),
      ],
    ),
  ],
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UsuarioProvider>(
          create: (context) => UsuarioProvider(),
          update: (context, authProvider, usuarioProvider) {
            // Le pasas el token de AuthProvider a tu UsuarioProvider
            return usuarioProvider!..updateToken(authProvider.token);
          },
        ),
      ],
      child: const MiAppWeb(),
    ),
  );
}

class MiAppWeb extends StatelessWidget {
  const MiAppWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'WIN BIN :D',
      theme: ThemeData(fontFamily: 'Courier'),
      routerConfig: _router,
    );
  }
}
