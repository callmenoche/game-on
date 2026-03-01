import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/match_provider.dart';
import 'providers/profile_provider.dart';
import 'router.dart';
import 'services/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
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
  late final _router = buildRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GameOn',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    const seedColor = Color(0xFF00C853);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: seedColor,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F5),
      cardTheme: CardThemeData(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor:
            isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
      ),
    );
  }
}
