import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../providers/profile_provider.dart';
import '../services/profile_service.dart';
import '../utils/error_helpers.dart';
import '../widgets/game_on_logo.dart';
import '../widgets/profile_form_fields.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1 state
  final Set<String> _selectedSports = {};

  // Step 2 state
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  final _bioController = TextEditingController();
  bool _isSubmitting = false;

  // Step 3 state
  DateTime? _birthDate;
  String?   _gender;
  bool      _showAge     = true;
  bool      _showGender  = true;
  bool      _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _usernameController = TextEditingController(text: profile?.username ?? '');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    await context.read<ProfileProvider>().completeOnboarding(
          username: _usernameController.text.trim(),
          favoriteSports: _selectedSports.toList(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          birthDate: _birthDate,
          gender: _gender,
          acceptedTermsAt: DateTime.now(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final error = context.read<ProfileProvider>().error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(error, AppLocalizations.of(context)!)), backgroundColor: Colors.redAccent),
      );
      context.read<ProfileProvider>().clearError();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _Step1(
                selectedSports: _selectedSports,
                onToggle: (sport) => setState(() {
                  if (_selectedSports.contains(sport)) {
                    _selectedSports.remove(sport);
                  } else {
                    _selectedSports.add(sport);
                  }
                }),
                onNext: _selectedSports.isNotEmpty ? () => _goToPage(1) : null,
                currentPage: _currentPage,
              ),
              _Step2(
                formKey: _formKey,
                usernameController: _usernameController,
                bioController: _bioController,
                isSubmitting: _isSubmitting,
                onBack: () => _goToPage(0),
                onNext: () {
                  if (_formKey.currentState!.validate()) _goToPage(2);
                },
                currentPage: _currentPage,
              ),
              _Step3(
                birthDate: _birthDate,
                gender: _gender,
                showAge: _showAge,
                showGender: _showGender,
                termsAccepted: _termsAccepted,
                onBirthDateChanged: (d) => setState(() => _birthDate = d),
                onGenderChanged: (g) => setState(() => _gender = g),
                onShowAgeChanged: (v) => setState(() => _showAge = v),
                onShowGenderChanged: (v) => setState(() => _showGender = v),
                onTermsChanged: (v) => setState(() => _termsAccepted = v),
                onBack: () => _goToPage(1),
                onFinish: _finish,
                isSubmitting: _isSubmitting,
                currentPage: _currentPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 1: Sports selection ───────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final Set<String> selectedSports;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;
  final int currentPage;

  const _Step1({
    required this.selectedSports,
    required this.onToggle,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GameOnLogo(size: 36, color: GameOnBrand.saffron),
          const SizedBox(height: 32),
          Text(
            l.welcomeToGameOn,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.pickSports,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: SportType.values.map((sport) {
                final isSelected = selectedSports.contains(sport.name);
                return GestureDetector(
                  onTap: () => onToggle(sport.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GameOnBrand.saffron
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? GameOnBrand.saffron
                            : GameOnBrand.slateLight.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sport.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sport.l10nLabel(context),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected
                                ? GameOnBrand.slateDark
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const _ProgressDots(total: 3, current: 0),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                disabledBackgroundColor:
                    GameOnBrand.saffron.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(AppLocalizations.of(context)!.next,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Profile setup ──────────────────────────────────────────────────

class _Step2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final int currentPage;

  const _Step2({
    required this.formKey,
    required this.usernameController,
    required this.bioController,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
    required this.currentPage,
  });

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  final _profileService = ProfileService();
  Timer? _debounce;
  bool? _usernameAvailable;
  bool _checkingUsername = false;

  @override
  void initState() {
    super.initState();
    widget.usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.usernameController.removeListener(_onUsernameChanged);
    super.dispose();
  }

  void _onUsernameChanged() {
    _debounce?.cancel();
    final text = widget.usernameController.text.trim();
    if (text.length < 3) {
      setState(() {
        _usernameAvailable = null;
        _checkingUsername = false;
      });
      return;
    }
    setState(() => _checkingUsername = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final available = await _profileService.isUsernameAvailable(text);
        if (mounted && widget.usernameController.text.trim() == text) {
          setState(() {
            _usernameAvailable = available;
            _checkingUsername = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _checkingUsername = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget? usernameSuffix;
    if (_checkingUsername) {
      usernameSuffix = const SizedBox(
        width: 18, height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: GameOnBrand.saffron),
      );
    } else if (_usernameAvailable == true) {
      usernameSuffix = const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20);
    } else if (_usernameAvailable == false) {
      usernameSuffix = const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
              label: Text(l.back),
              style: TextButton.styleFrom(
                foregroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.yourProfile,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.whatShouldWeCallYou,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.usernameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.exampleUsername,
                prefixIcon: const Icon(Icons.alternate_email_rounded,
                    size: 18, color: GameOnBrand.saffron),
                suffixIcon: usernameSuffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: usernameSuffix,
                      )
                    : null,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.usernameRequired;
                if (v.trim().length < 3) return l.usernameTooShort;
                if (v.trim().length > 20) return l.usernameTooLong;
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                  return l.usernameCharset;
                }
                if (_usernameAvailable == false) return l.usernameTaken;
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  l.aFewWordsAboutYou,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l.optional,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.bioController,
              maxLines: 3,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: l.exampleBio,
              ),
            ),
            const SizedBox(height: 8),
            const _ProgressDots(total: 3, current: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _usernameAvailable == false || _checkingUsername
                    ? null
                    : widget.onNext,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: GameOnBrand.saffron,
                  foregroundColor: GameOnBrand.slateDark,
                  disabledBackgroundColor:
                      GameOnBrand.saffron.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l.next,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Birthdate + gender ─────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final DateTime? birthDate;
  final String? gender;
  final bool showAge;
  final bool showGender;
  final bool termsAccepted;
  final ValueChanged<DateTime?> onBirthDateChanged;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<bool> onShowAgeChanged;
  final ValueChanged<bool> onShowGenderChanged;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final bool isSubmitting;
  final int currentPage;

  const _Step3({
    required this.birthDate,
    required this.gender,
    required this.showAge,
    required this.showGender,
    required this.termsAccepted,
    required this.onBirthDateChanged,
    required this.onGenderChanged,
    required this.onShowAgeChanged,
    required this.onShowGenderChanged,
    required this.onTermsChanged,
    required this.onBack,
    required this.onFinish,
    required this.isSubmitting,
    required this.currentPage,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: GameOnBrand.saffron,
                onPrimary: GameOnBrand.slateDark,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onBirthDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
            label: Text(l.back),
            style: TextButton.styleFrom(
              foregroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.5),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.almostThere,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l.optionalInfoSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 28),

          // ── Date of birth ──────────────────────────────────────────────
          Text(
            l.dateOfBirth,
            style:
                theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DateField(
            value: birthDate,
            onTap: () => _pickDate(context),
          ),
          if (birthDate != null) ...[
            const SizedBox(height: 8),
            PrivacyToggle(
              label: l.showAgeOnProfile,
              value: showAge,
              onChanged: onShowAgeChanged,
            ),
          ],
          const SizedBox(height: 24),

          // ── Gender ─────────────────────────────────────────────────────
          Text(
            l.gender,
            style:
                theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GenderPicker(
            value: gender,
            onChanged: onGenderChanged,
          ),
          if (gender != null) ...[
            const SizedBox(height: 8),
            PrivacyToggle(
              label: l.showGenderOnProfile,
              value: showGender,
              onChanged: onShowGenderChanged,
            ),
          ],
          const SizedBox(height: 24),
          _TermsCheckbox(
            accepted: termsAccepted,
            onChanged: onTermsChanged,
          ),
          const SizedBox(height: 16),
          const _ProgressDots(total: 3, current: 2),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting || !termsAccepted ? null : onFinish,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: GameOnBrand.slateDark),
                    )
                  : Text(l.letsGo,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Terms checkbox ─────────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!accepted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: accepted,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: GameOnBrand.saffron,
              checkColor: GameOnBrand.slateDark,
              side: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                children: [
                  TextSpan(text: l.iAcceptThe),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => context.push('/terms'),
                      child: Text(
                        l.termsOfService,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: l.andThe),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => context.push('/privacy'),
                      child: Text(
                        l.privacyPolicy,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress dots ──────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int total;
  final int current;

  const _ProgressDots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? GameOnBrand.saffron
                : GameOnBrand.saffron.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
