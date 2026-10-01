import 'package:flutter/material.dart';

import 'widgets_profile/profile_app_bar.dart';
import 'widgets_profile/avatar_card.dart';
import 'widgets_profile/stats_card.dart';
import 'widgets_profile/player_details_card.dart';
import 'package:winbin/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    
    if (context.mounted) {  
      context.go('/login');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: const ProfileAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 700;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return  Column(
      children: [
        const AvatarCard(),
        const SizedBox(height: 12),
        const StatsCard(),
        const SizedBox(height: 12),
        const PlayerDetailsCard(),
        const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _cerrarSesion(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AvatarCard(),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              StatsCard(),
              SizedBox(height: 12),
              PlayerDetailsCard(),
            ],
          ),
        ),
      ],
    );
  }
}