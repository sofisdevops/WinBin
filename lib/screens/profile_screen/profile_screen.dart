import 'package:flutter/material.dart';

import 'widgets_profile/profile_app_bar.dart';
import 'widgets_profile/avatar_card.dart';
import 'widgets_profile/stats_card.dart';
import 'widgets_profile/player_details_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      children: [
        AvatarCard(),
        SizedBox(height: 12),
        StatsCard(),
        SizedBox(height: 12),
        PlayerDetailsCard(),
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
        SizedBox(width: 16),
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