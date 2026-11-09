import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:winbin/Providers/AuthProvider.dart';

class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key, this.uri});

  final String? uri;

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen>
    with SingleTickerProviderStateMixin {
  // Paleta WIN BIN
  static const Color _verdeOscuro = Color(0xFF1B5E20);
  static const Color _verde = Color(0xFF2E7D32);
  static const Color _verdeClaro = Color(0xFF66BB6A);
  static const Color _fondoClaro = Color(0xFFE8F5E9);

  late final AnimationController _controller;
  late final Animation<double> _flotar;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _flotar = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final bool logueado = auth.token != null;
    final String destino =
        !logueado ? '/login' : (auth.rol == 'ADMIN' ? '/admin' : '/ranking');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_fondoClaro, Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          ),
        ),
        child: Stack(
          children: [
            // Círculos decorativos de fondo
            Positioned(
              top: -60,
              left: -60,
              child: _circuloDecorativo(200, _verdeClaro.withAlpha(60)),
            ),
            Positioned(
              bottom: -80,
              right: -40,
              child: _circuloDecorativo(260, _verde.withAlpha(40)),
            ),
            Positioned(
              bottom: 120,
              left: 30,
              child: _circuloDecorativo(70, _verdeClaro.withAlpha(50)),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _verdeOscuro.withAlpha(40),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 4 [reciclaje] 4
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _numero('4'),
                                const SizedBox(width: 8),
                                AnimatedBuilder(
                                  animation: _flotar,
                                  builder: (context, child) =>
                                      Transform.translate(
                                    offset: Offset(0, _flotar.value),
                                    child: child,
                                  ),
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [_verdeClaro, _verde],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.recycling,
                                      size: 68,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _numero('4'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          const Text(
                            '¡Ups! Esta página fue reciclada',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _verdeOscuro,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.uri != null
                                ? 'No encontramos la ruta "${widget.uri}".\nPero no te preocupes, aún puedes seguir sumando puntos.'
                                : 'No encontramos lo que buscabas.\nPero aún puedes seguir sumando puntos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Botón principal
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.icon(
                              onPressed: () => context.go(destino),
                              style: FilledButton.styleFrom(
                                backgroundColor: _verde,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: Icon(
                                logueado ? Icons.eco : Icons.login,
                              ),
                              label: Text(
                                logueado ? 'Volver al inicio' : 'Ir al login',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Botón secundario: volver atrás
                          if (context.canPop()) ...[
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: _verde,
                              ),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Regresar'),
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco, size: 16, color: _verdeClaro),
                              SizedBox(width: 6),
                              Text(
                                'WIN BIN · Recicla, suma y gana',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _verde,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numero(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 110,
        fontWeight: FontWeight.w900,
        height: 1,
        color: _verdeOscuro,
      ),
    );
  }

  Widget _circuloDecorativo(double tamano, Color color) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}