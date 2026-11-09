import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:winbin/main.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Inicio'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MiAppWeb(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
  });
}