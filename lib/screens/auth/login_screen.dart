import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_helpers.dart';
import '../../widgets/game_on_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureSignUpPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      context.read<AuthProvider>().clearError();
      setState(() {}); // refresh button label
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingEmail =
        context.watch<AuthProvider>().pendingConfirmationEmail;

    return Scaffold(
      backgroundColor: GameOnBrand.slateDark,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: pendingEmail != null
            ? _CheckEmailView(email: pendingEmail)
            : Column(
                children: [
                  // ── Scrollable content ─────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          _buildHeader(theme),
                          const SizedBox(height: 36),
                          _buildTabBar(theme),
                          const SizedBox(height: 24),
                          AnimatedBuilder(
                            animation: _tabController,
                            builder: (_, __) => _tabController.index == 0
                                ? _SignInForm(
                                    formKey: _signInFormKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    onToggleObscure: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  )
                                : _SignUpForm(
                                    formKey: _signUpFormKey,
                                    emailController: _signUpEmailController,
                                    passwordController:
                                        _signUpPasswordController,
                                    obscurePassword: _obscureSignUpPassword,
                                    onToggleObscure: () => setState(() =>
                                        _obscureSignUpPassword =
                                            !_obscureSignUpPassword),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          _buildErrorBanner(),
                        ],
                      ),
                    ),
                  ),

                  // ── Pinned submit button ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: _buildSubmitButton(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        const GameOnLogoContainer(size: 88),
        const SizedBox(height: 20),
        const Text(
          'GameOn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l.findYourNextMatch,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF243044),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: GameOnBrand.saffron,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: GameOnBrand.slateDark,
        unselectedLabelColor: Colors.white54,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        tabs: [Tab(text: l.signIn), Tab(text: l.signUp)],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.error == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withValues(alpha: 0.4),
            border: Border.all(color: Colors.red.shade700),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  friendlyError(auth.error, AppLocalizations.of(context)!),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    final l = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        return FilledButton(
          onPressed: auth.isLoading ? null : _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: GameOnBrand.saffron,
            foregroundColor: GameOnBrand.slateDark,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: GameOnBrand.slateDark,
                  ),
                )
              : Text(
                  _tabController.index == 0 ? l.signIn : l.createAccount,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
        );
      },
    );
  }

  void _submit() {
    final auth = context.read<AuthProvider>();
    if (_tabController.index == 0) {
      if (!_signInFormKey.currentState!.validate()) return;
      auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      if (!_signUpFormKey.currentState!.validate()) return;
      auth.signUp(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
      );
    }
  }
}

// ─── Check-your-email view ──────────────────────────────────────────────────

class _CheckEmailView extends StatefulWidget {
  final String email;
  const _CheckEmailView({required this.email});

  @override
  State<_CheckEmailView> createState() => _CheckEmailViewState();
}

class _CheckEmailViewState extends State<_CheckEmailView> {
  bool _isResending = false;

  Future<void> _resend() async {
    setState(() => _isResending = true);
    final ok = await context.read<AuthProvider>().resendConfirmationEmail();
    if (!mounted) return;
    setState(() => _isResending = false);
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l.confirmationEmailResent : l.errorGeneric),
        backgroundColor: ok ? GameOnBrand.saffron : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: GameOnBrand.saffron.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_rounded,
                size: 40, color: GameOnBrand.saffron),
          ),
          const SizedBox(height: 24),
          Text(
            l.checkYourEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.checkYourEmailBody(widget.email),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isResending ? null : _resend,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isResending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: GameOnBrand.slateDark),
                    )
                  : Text(l.resendEmail,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<AuthProvider>().cancelPendingConfirmation(),
            child: Text(l.backToSignIn,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          ),
        ],
      ),
    );
  }
}

// ─── Sign In Form ──────────────────────────────────────────────────────────────

class _SignInForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  const _SignInForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: Column(
        children: [
          _GameOnField(
            controller: emailController,
            label: l.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? l.invalidEmail : null,
          ),
          const SizedBox(height: 14),
          _GameOnField(
            controller: passwordController,
            label: l.password,
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? l.passwordTooShort : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPasswordDialog(context),
              style: TextButton.styleFrom(
                foregroundColor: GameOnBrand.saffron,
                padding: const EdgeInsets.only(top: 4),
              ),
              child: Text(l.forgotPassword,
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  static void _showForgotPasswordDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: GameOnBrand.slateCard,
          title: Text(l.forgotPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.resetPasswordSent,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l.email,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty || !email.contains('@')) return;
                Navigator.of(ctx).pop();
                await context.read<AuthProvider>().resetPassword(email: email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.resetPasswordSent)),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
              ),
              child: Text(l.send),
            ),
          ],
        );
      },
    );
  }
}

// ─── Sign Up Form ──────────────────────────────────────────────────────────────

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  const _SignUpForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: Column(
        children: [
          _GameOnField(
            controller: emailController,
            label: l.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? l.invalidEmail : null,
          ),
          const SizedBox(height: 14),
          _GameOnField(
            controller: passwordController,
            label: l.password,
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? l.passwordTooShort : null,
          ),
        ],
      ),
    );
  }
}

// ─── Shared field ──────────────────────────────────────────────────────────────

class _GameOnField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _GameOnField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon:
            Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.4)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF243044),
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
    );
  }
}
