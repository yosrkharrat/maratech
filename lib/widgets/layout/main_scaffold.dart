import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/accessibility/a11y.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/club')) return 2;
    if (location.startsWith('/profile') || location.startsWith('/admin')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final isAdmin = ref.watch(isAdminProvider);
    final isVisitor = ref.watch(isVisitorProvider);
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/events');
              break;
            case 2:
              context.go('/club');
              break;
            case 3:
              if (isVisitor) {
                context.go('/login');
              } else if (isAdmin) {
                context.go('/admin');
              } else {
                context.go('/profile');
              }
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: A11y.label(
              label: tr('home'),
              child: const Icon(Icons.home_outlined),
            ),
            selectedIcon: const Icon(Icons.home),
            label: tr('home'),
          ),
          NavigationDestination(
            icon: A11y.label(
              label: tr('events'),
              child: const Icon(Icons.directions_run_outlined),
            ),
            selectedIcon: const Icon(Icons.directions_run),
            label: tr('events'),
          ),
          NavigationDestination(
            icon: A11y.label(
              label: tr('club'),
              child: const Icon(Icons.groups_outlined),
            ),
            selectedIcon: const Icon(Icons.groups),
            label: tr('club'),
          ),
          NavigationDestination(
            icon: A11y.label(
              label: isVisitor
                  ? tr('login')
                  : isAdmin
                      ? tr('admin')
                      : tr('profile'),
              child: Icon(
                isVisitor
                    ? Icons.login
                    : isAdmin
                        ? Icons.admin_panel_settings_outlined
                        : Icons.person_outline,
              ),
            ),
            selectedIcon: Icon(
              isVisitor
                  ? Icons.login
                  : isAdmin
                      ? Icons.admin_panel_settings
                      : Icons.person,
            ),
            label: isVisitor
                ? tr('login')
                : isAdmin
                    ? tr('admin')
                    : tr('profile'),
          ),
        ],
      ),
    );
  }
}
