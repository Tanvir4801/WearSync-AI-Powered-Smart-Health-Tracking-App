import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const List<String> _routes = <String>[
    '/shell',
    '/activity',
    '/devices',
    '/chat',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth_rounded),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (int index) {
          context.go(_routes[index]);
        },
        backgroundColor: AppTheme.surface,
        height: 68,
        indicatorColor: AppTheme.primaryAccent.withValues(alpha: 0.15),
      ),
    );
  }
}
