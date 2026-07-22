import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/profile_provider.dart';
import 'widgets/game_on_logo.dart';
import 'screens/auth/login_screen.dart';
import 'screens/create_match_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/match_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/public_profile_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/create_group_screen.dart';
import 'screens/group_detail_screen.dart';
import 'screens/legal_screen.dart';
import 'legal/legal_content.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthProvider authProvider, ProfileProvider profileProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([authProvider, profileProvider]),
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) return null; // always let splash through

      final isAuth = authProvider.isAuthenticated;
      final loc = state.matchedLocation;

      if (!isAuth && loc != '/login' && loc != '/terms' && loc != '/privacy') return '/login';
      if (isAuth && loc == '/login') return '/';

      final profileLoaded = profileProvider.profile != null;
      final onboarded = profileProvider.profile?.onboarded ?? true;

      if (isAuth && profileLoaded && !onboarded && loc != '/onboarding') {
        return '/onboarding';
      }
      if (isAuth && loc == '/onboarding' && onboarded) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (_, __) => const LegalScreen(type: LegalPageType.terms),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const LegalScreen(type: LegalPageType.privacy),
      ),
      // Web-only landing spot for shared https://…/claim?claimCode=&match= links
      // (mirrors the io.supabase.gameon://claim custom scheme). Registering
      // it here just stops go_router's own initial-URL matching from
      // erroring on an unknown path on cold boot — the actual navigation
      // into the match + claim sheet is handled by the app_links-driven
      // _handleDeepLink/_pendingMatchId flow in main.dart, same as native.
      GoRoute(
        path: '/claim',
        redirect: (context, state) => '/',
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const FeedScreen(),
          ),
          GoRoute(
            path: '/match/:id',
            builder: (_, state) => MatchDetailScreen(
              matchId: state.pathParameters['id']!,
              initialClaimCode: (state.extra as Map?)?['claimCode'] as String?,
            ),
          ),
          GoRoute(
            path: '/create-match',
            builder: (_, __) => const CreateMatchScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/groups',
            builder: (_, __) => const GroupsScreen(),
          ),
          GoRoute(
            path: '/groups/create',
            builder: (_, __) => const CreateGroupScreen(),
          ),
          GoRoute(
            path: '/groups/:id',
            builder: (_, state) =>
                GroupDetailScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/player/:userId',
            builder: (_, state) => PublicProfileScreen(
                userId: state.pathParameters['userId']!),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Bottom navigation shell shared across authenticated screens.
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _paths = ['/', '/calendar', '/groups', '/profile'];
  static final _icons = [
    PhosphorIconsLight.lightning,
    PhosphorIconsLight.calendarBlank,
    PhosphorIconsLight.users,
    PhosphorIconsLight.user,
  ];
  static final _activeIcons = [
    PhosphorIconsFill.lightning,
    PhosphorIconsFill.calendarBlank,
    PhosphorIconsFill.users,
    PhosphorIconsFill.user,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels = [l.feed, l.calendar, l.community, l.profile];
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _paths.indexWhere((p) => p == location).clamp(0, 3);

    final isOffline = !context.watch<ConnectivityProvider>().isOnline;

    return Scaffold(
      body: Column(
        children: [
          if (isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.redAccent,
              child: Text(
                l.connectionLost,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: List.generate(
          4,
          (i) => NavigationDestination(
            icon: PhosphorIcon(_icons[i]),
            selectedIcon: PhosphorIcon(_activeIcons[i],
                color: GameOnBrand.saffron),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}
