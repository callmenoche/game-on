import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/group_provider.dart';
import 'providers/language_provider.dart';
import 'providers/match_provider.dart';
import 'providers/profile_provider.dart';
import 'router.dart';
import 'services/supabase_client.dart';
import 'widgets/game_on_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const GameOnApp(),
    ),
  );
}

class GameOnApp extends StatefulWidget {
  const GameOnApp({super.key});

  @override
  State<GameOnApp> createState() => _GameOnAppState();
}

class _GameOnAppState extends State<GameOnApp> {
  late final GoRouter _router;
  late final AppLinks _appLinks;

  // Pending deep link stored when the app isn't ready yet (cold start / not authed)
  String? _pendingMatchId;
  String? _pendingClaimCode;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(
      context.read<AuthProvider>(),
      context.read<ProfileProvider>(),
    );
    _initDeepLinks();
    // Navigate to a pending link once auth + profile are ready
    context.read<AuthProvider>().addListener(_onReadyCheck);
    context.read<ProfileProvider>().addListener(_onReadyCheck);
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_onReadyCheck);
    context.read<ProfileProvider>().removeListener(_onReadyCheck);
    super.dispose();
  }

  /// Called whenever auth or profile state changes.
  /// If a deep link arrived before the app was ready, navigate now.
  void _onReadyCheck() {
    if (_pendingMatchId == null) return;
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    if (!auth.isAuthenticated) return;
    if (profile.profile == null) return; // still loading
    final matchId = _pendingMatchId!;
    final code = _pendingClaimCode;
    _pendingMatchId = null;
    _pendingClaimCode = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _router.push('/match/$matchId',
            extra: code != null ? {'claimCode': code} : null);
      }
    });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleDeepLink(initialUri);
    _appLinks.uriLinkStream.listen(_handleDeepLink, onError: (_) {});
  }

  static final _uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false);

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'io.supabase.gameon' && uri.host == 'claim') {
      final code = uri.queryParameters['code'];
      final matchId = uri.queryParameters['match'];
      if (code == null || code.isEmpty || matchId == null || matchId.isEmpty) {
        return;
      }
      if (!_uuidPattern.hasMatch(matchId)) return;
      final auth = context.read<AuthProvider>();
      final profile = context.read<ProfileProvider>();
      if (auth.isAuthenticated && profile.profile != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _router.push('/match/$matchId', extra: {'claimCode': code});
          }
        });
      } else {
        _pendingMatchId = matchId;
        _pendingClaimCode = code;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (_, langProvider, __) => MaterialApp.router(
        title: 'GameOn',
        debugShowCheckedModeBanner: false,
        locale: langProvider.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: ThemeMode.dark, // default to dark — brand feels right here
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        routerConfig: _router,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Derive a full M3 colour scheme from the Saffron seed
    final scheme = ColorScheme.fromSeed(
      seedColor: GameOnBrand.saffron,
      brightness: brightness,
    ).copyWith(
      // Override key slots with exact brand tokens
      primary: GameOnBrand.saffron,
      onPrimary: GameOnBrand.onSaffron,
      surface: isDark ? const Color(0xFF243044) : Colors.white,
      onSurface: isDark ? Colors.white : GameOnBrand.slateDark,
      surfaceContainerHighest:
          isDark ? const Color(0xFF2D3F57) : const Color(0xFFEFF3F8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? GameOnBrand.slateDark : const Color(0xFFF1F5F9),

      // App bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor:
            isDark ? GameOnBrand.slateDark : Colors.white,
        foregroundColor: isDark ? Colors.white : GameOnBrand.slateDark,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF243044) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),

      // Filled buttons → Saffron background, dark text
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GameOnBrand.saffron,
          foregroundColor: GameOnBrand.onSaffron,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // Bottom nav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF162032) : Colors.white,
        indicatorColor:
            GameOnBrand.saffron.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: GameOnBrand.saffron);
          }
          return IconThemeData(
              color: isDark
                  ? Colors.white54
                  : GameOnBrand.slateDark.withValues(alpha: 0.45));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: GameOnBrand.saffron,
                fontWeight: FontWeight.w700,
                fontSize: 12);
          }
          return const TextStyle(fontSize: 12);
        }),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF2D3F57)
            : const Color(0xFFEFF3F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: GameOnBrand.saffron, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
