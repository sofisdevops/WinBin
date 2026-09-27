import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'Providers/UsuarioProvider.dart';
import 'package:provider/provider.dart';
import 'package:winbin/screens/login_screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:winbin/screens/admin_screen/main_layout.dart';
import 'package:winbin/screens/login_screens/register_screen.dart';


final GoRouter _router = GoRouter(
  initialLocation: '/login', 
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
    ),
    
  ],
);
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProxyProvider<AuthProvider, UsuarioProvider>(
      create: (context) => UsuarioProvider(),
      update: (context, authProvider, usuarioProvider) {
        // Le pasas el token de AuthProvider a tu UsuarioProvider
        return usuarioProvider!..updateToken(authProvider.token);
      },
    ),
    ],child: const MiAppWeb(),)
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
