import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for the Supabase client.
///
/// Call [SupabaseService.initialize] once in [main] before [runApp].
/// Anywhere in the app, use [SupabaseService.client] to reach the SDK.
class SupabaseService {
  SupabaseService._();

  // ── Credentials ──────────────────────────────────────────────────────────
  // Store these in a .env file (or --dart-define) and NEVER commit secrets.
  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // ── Initialisation ────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    assert(
      _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty,
      'Missing Supabase credentials. '
      'Pass --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      // Persist sessions across cold starts
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      debug: false, // flip to true during local development
    );
  }

  // ── Accessors ─────────────────────────────────────────────────────────────

  /// The raw Supabase client – use for one-off queries.
  static SupabaseClient get client => Supabase.instance.client;

  /// Shorthand for the currently authenticated user (null if logged out).
  static User? get currentUser => client.auth.currentUser;

  /// Typed table helper – avoids string typos.
  static SupabaseQueryBuilder table(String name) => client.from(name);

  // ── Auth helpers ──────────────────────────────────────────────────────────

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) =>
      client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      client.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() => client.auth.signOut();

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
