import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/activity/screens/activity_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/devices/screens/devices_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../widgets/main_shell.dart';

Future<void> initializeRouter() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;
      final String location = state.matchedLocation;
      final bool onSplashRoute = location == '/splash';
      final bool onLoginRoute = location == '/login';

      if (onSplashRoute) {
        return null;
      }

      if (!loggedIn && !onLoginRoute) {
        return '/login';
      }

      if (loggedIn && onLoginRoute) {
        return '/shell';
      }

      if (location == '/') {
        return loggedIn ? '/shell' : '/login';
      }

      return null;
    } catch (e) {
      debugPrint('Router redirect error: $e');
      return '/login';
    }
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/shell',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/activity',
              builder: (BuildContext context, GoRouterState state) {
                return const ActivityScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/devices',
              builder: (BuildContext context, GoRouterState state) {
                return const DevicesScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/chat',
              builder: (BuildContext context, GoRouterState state) {
                return const ChatScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) {
                return const ProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
