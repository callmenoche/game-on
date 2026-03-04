import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/profile_provider.dart';
import '../widgets/game_on_logo.dart';

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
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final error = context.read<ProfileProvider>().error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
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
                onFinish: _finish,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GameOnLogo(size: 36),
          const SizedBox(height: 32),
          Text(
            'Welcome to GameOn!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick the sports you play:',
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
                          : GameOnBrand.slateCard,
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
                          sport.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected
                                ? GameOnBrand.slateDark
                                : Colors.white.withValues(alpha: 0.85),
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
          const _ProgressDots(total: 2, current: 0),
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
              child: const Text('Next →',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Profile setup ──────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final int currentPage;

  const _Step2({
    required this.formKey,
    required this.usernameController,
    required this.bioController,
    required this.isSubmitting,
    required this.onBack,
    required this.onFinish,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Profile',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What should we call you?',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: usernameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. striker99',
                prefixIcon: Icon(Icons.alternate_email_rounded,
                    size: 18, color: GameOnBrand.saffron),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Username required';
                if (v.trim().length < 3) return 'At least 3 characters';
                if (v.trim().length > 20) return 'Max 20 characters';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                  return 'Letters, numbers, and _ only';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'A few words about you',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(optional)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: bioController,
              maxLines: 3,
              maxLength: 120,
              decoration: const InputDecoration(
                hintText: 'e.g. Weekend warrior, love 5-a-side...',
              ),
            ),
            const SizedBox(height: 8),
            const _ProgressDots(total: 2, current: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : onFinish,
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
                            strokeWidth: 2.5,
                            color: GameOnBrand.slateDark),
                      )
                    : const Text("Let's Go!",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
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
