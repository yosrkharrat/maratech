import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/events/events_list_screen.dart';
import '../../screens/events/event_detail_screen.dart';
import '../../screens/events/event_create_screen.dart';
import '../../screens/events/event_calendar_screen.dart';
import '../../screens/media/gallery_screen.dart';
import '../../screens/media/upload_media_screen.dart';
import '../../screens/club/club_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/manage_users_screen.dart';
import '../../screens/strava/strava_connect_screen.dart';
import '../../screens/strava/classement_screen.dart';
import '../../widgets/layout/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Events
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsListScreen(),
            routes: [
              GoRoute(
                path: 'calendar',
                name: 'event-calendar',
                builder: (context, state) => const EventCalendarScreen(),
              ),
              GoRoute(
                path: 'create',
                name: 'event-create',
                builder: (context, state) => const EventCreateScreen(),
              ),
              GoRoute(
                path: ':eventId',
                name: 'event-detail',
                builder: (context, state) {
                  final eventId = state.pathParameters['eventId']!;
                  return EventDetailScreen(eventId: eventId);
                },
                routes: [
                  GoRoute(
                    path: 'gallery',
                    name: 'event-gallery',
                    builder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      return GalleryScreen(eventId: eventId);
                    },
                  ),
                  GoRoute(
                    path: 'upload',
                    name: 'event-upload',
                    builder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      return UploadMediaScreen(eventId: eventId);
                    },
                  ),
                  GoRoute(
                    path: 'classement',
                    name: 'event-classement',
                    builder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      return ClassementScreen(eventId: eventId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Club
          GoRoute(
            path: '/club',
            name: 'club',
            builder: (context, state) => const ClubScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'strava',
                name: 'strava-connect',
                builder: (context, state) =>
                    const StravaConnectScreen(),
              ),
            ],
          ),

          // Admin
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
            routes: [
              GoRoute(
                path: 'users',
                name: 'admin-users',
                builder: (context, state) =>
                    const ManageUsersScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
