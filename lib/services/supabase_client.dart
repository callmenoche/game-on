import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for the Supabase client.
///
/// Call [SupabaseService.initialize] once in [main] before [runApp].
/// Anywhere in the app, use [SupabaseService.client] to reach the SDK.
class SupabaseService {
  SupabaseService._();

  // ── Credentials ──────────────────────────────────────────────────────────
  // Store these in a .env file (or --dart-define) and NEVER commit secrets.
  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // ── Initialisation ────────────────────────────────────────────────────────
  static Future<void> initialize() async {
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

  // Same custom scheme as guest-claim deep links (see main.dart). The SDK's
  // PKCE flow auto-detects any incoming URI with a `code` param as an auth
  // callback and exchanges it for a session — no extra deep-link code needed.
  static const String _emailRedirectTo = 'io.supabase.gameon://login-callback';

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _emailRedirectTo,
      );

  static Future<void> resendConfirmationEmail(String email) => client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: _emailRedirectTo,
      );

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      client.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() => client.auth.signOut();

  static Future<void> resetPasswordForEmail(String email) =>
      client.auth.resetPasswordForEmail(email);

  static Future<void> deleteAccount() => client.rpc('delete_own_account');

  static Future<UserResponse> updatePassword(String newPassword) =>
      client.auth.updateUser(UserAttributes(password: newPassword));

  static Future<UserResponse> updatePhone(String phone) =>
      client.auth.updateUser(UserAttributes(phone: phone));

  static String? get currentUserPhone => client.auth.currentUser?.phone;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
