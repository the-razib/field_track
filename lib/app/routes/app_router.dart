import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/features/auth/presentation/screens/login_screen.dart';
import 'package:field_track/features/auth/presentation/screens/register_screen.dart';
import 'package:field_track/features/auth/presentation/screens/splash_screen.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/presentation/screens/add_edit_location_screen.dart';
import 'package:field_track/features/locations/presentation/screens/locations_list_screen.dart';
import 'package:field_track/features/profile/presentation/screens/profile_screen.dart';
import 'package:field_track/features/sync/presentation/screens/sync_screen.dart';
import 'package:field_track/features/todos/presentation/screens/todo_list_screen.dart';
import 'package:field_track/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TodoListScreen(),
          ),
          GoRoute(
            path: '/locations',
            builder: (context, state) => const LocationsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddEditLocationScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final location = state.extra as GeoLocation?;
                  return AddEditLocationScreen(existingLocation: location);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/sync',
            builder: (context, state) => const SyncScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
