import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../services/bug_report_service.dart';
import '../services/places_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/game_on_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(label: l.account, icon: PhosphorIconsLight.user),
          _ChangePasswordTile(),
          _PhoneTile(),
          const _SignOutTile(),
          _DeleteAccountTile(),
          const _Divider(),

          _SectionHeader(label: l.globalSection, icon: PhosphorIconsLight.globe),
          _LanguageTile(),
          _DefaultLocationTile(),
          _AppearanceTile(),
          const _Divider(),

          _SectionHeader(
              label: l.supportSection, icon: PhosphorIconsLight.lifebuoy),
          const _ReportBugTile(),
          const _Divider(),

          _SectionHeader(label: l.legalSection, icon: PhosphorIconsLight.scales),
          ListTile(
            leading: PhosphorIcon(PhosphorIconsLight.fileText,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            title: Text(
              l.termsOfService,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            onTap: () => context.push('/terms'),
          ),
          ListTile(
            leading: PhosphorIcon(PhosphorIconsLight.shieldCheck,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            title: Text(
              l.privacyPolicy,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            onTap: () => context.push('/privacy'),
          ),
          const SizedBox(height: 32),
          const _VersionLabel(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Change Password tile (not functional yet — greyed out) ─────────────────

class _ChangePasswordTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final color = theme.colorScheme.onSurface;

    return ListTile(
      enabled: false,
      leading: PhosphorIcon(PhosphorIconsLight.lock,
          size: 20, color: color.withValues(alpha: 0.25)),
      title: Text(
        l.changePassword,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.35),
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        l.comingSoon,
        style: TextStyle(
          fontSize: 12,
          color: color.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

// ─── Phone tile (not functional yet — greyed out) ───────────────────────────

class _PhoneTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final color = theme.colorScheme.onSurface;

    return ListTile(
      enabled: false,
      leading: PhosphorIcon(PhosphorIconsLight.phone,
          size: 20, color: color.withValues(alpha: 0.25)),
      title: Text(
        l.phoneNumber,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.35),
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        l.comingSoon,
        style: TextStyle(
          fontSize: 12,
          color: color.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

// ─── Appearance tile ────────────────────────────────────────────────────────

class _AppearanceTile extends StatelessWidget {
  String _modeName(AppLocalizations l, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l.systemTheme;
      case ThemeMode.light:
        return l.lightTheme;
      case ThemeMode.dark:
        return l.darkTheme;
    }
  }

  IconData _modeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return PhosphorIconsLight.deviceMobile;
      case ThemeMode.light:
        return PhosphorIconsLight.sun;
      case ThemeMode.dark:
        return PhosphorIconsLight.moon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final color = theme.colorScheme.onSurface;
    final current = context.watch<ThemeProvider>().themeMode;

    return ListTile(
      leading: PhosphorIcon(PhosphorIconsLight.moon,
          size: 20, color: color.withValues(alpha: 0.7)),
      title: Text(
        l.appearance,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        _modeName(l, current),
        style: TextStyle(
          fontSize: 12,
          color: color.withValues(alpha: 0.45),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 18, color: color.withValues(alpha: 0.3)),
      onTap: () => _showSheet(context, l, current),
    );
  }

  void _showSheet(
      BuildContext context, AppLocalizations l, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  l.chooseAppearance,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ...ThemeMode.values.map((mode) {
                  final selected = mode == current;
                  return ListTile(
                    leading: PhosphorIcon(_modeIcon(mode), size: 22),
                    title: Text(
                      _modeName(l, mode),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? GameOnBrand.saffron : null,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_rounded,
                            color: GameOnBrand.saffron)
                        : null,
                    onTap: () {
                      context.read<ThemeProvider>().setThemeMode(mode);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Default Location tile ──────────────────────────────────────────────────

class _DefaultLocationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final color = theme.colorScheme.onSurface;
    final profile = context.watch<ProfileProvider>().profile;
    final locationName = profile?.defaultLocationName;

    return ListTile(
      leading: PhosphorIcon(PhosphorIconsLight.mapPin,
          size: 20, color: color.withValues(alpha: 0.7)),
      title: Text(
        l.defaultLocation,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        (locationName != null && locationName.isNotEmpty)
            ? locationName
            : l.notSet,
        style: TextStyle(
          fontSize: 12,
          color: color.withValues(alpha: 0.45),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 18, color: color.withValues(alpha: 0.3)),
      onTap: () => _showLocationDialog(context),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _DefaultLocationDialog(),
    );
  }
}

class _DefaultLocationDialog extends StatefulWidget {
  const _DefaultLocationDialog();

  @override
  State<_DefaultLocationDialog> createState() => _DefaultLocationDialogState();
}

class _DefaultLocationDialogState extends State<_DefaultLocationDialog> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _searching = false;
  String _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();
  String? _selectedName;
  double? _selectedLat;
  double? _selectedLng;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    if (profile?.defaultLocationName != null) {
      _controller.text = profile!.defaultLocationName!;
      _selectedName = profile.defaultLocationName;
      _selectedLat = profile.defaultGeoLat;
      _selectedLng = profile.defaultGeoLng;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Clear selection when user types
    _selectedName = null;
    _selectedLat = null;
    _selectedLng = null;

    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      final results =
          await PlacesService.autocomplete(value, _sessionToken);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _searching = false;
        });
      }
    });
  }

  Future<void> _onSuggestionTap(PlaceSuggestion suggestion) async {
    final token = _sessionToken;
    _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();
    setState(() {
      _suggestions = [];
      _searching = true;
    });
    final details = await PlacesService.getDetails(suggestion.placeId, token);
    if (!mounted) return;
    setState(() => _searching = false);
    if (details != null) {
      final name = suggestion.secondaryText.isNotEmpty
          ? '${suggestion.mainText}, ${suggestion.secondaryText}'
          : suggestion.mainText;
      _controller.text = name;
      _selectedName = name;
      _selectedLat = details.lat;
      _selectedLng = details.lng;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      title: Text(l.defaultLocation),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                hintText: l.defaultLocationSubtitle,
                prefixIcon: Icon(Icons.location_on_outlined,
                    size: 20,
                    color: GameOnBrand.saffron.withValues(alpha: 0.8)),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            if (_suggestions.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (ctx, i) {
                    final s = _suggestions[i];
                    return InkWell(
                      onTap: () => _onSuggestionTap(s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 16,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(s.mainText,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  if (s.secondaryText.isNotEmpty)
                                    Text(s.secondaryText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme
                                              .colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: (_selectedName != null &&
                  _selectedLat != null &&
                  _selectedLng != null &&
                  !_isSaving)
              ? () async {
                  setState(() => _isSaving = true);
                  final provider = context.read<ProfileProvider>();
                  await provider.saveDefaultLocation(
                    name: _selectedName!,
                    lat: _selectedLat!,
                    lng: _selectedLng!,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              : null,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.save),
        ),
      ],
    );
  }
}

// ─── Language tile ──────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  static const _locales = [
    Locale('en'),
    Locale('fr'),
    Locale('es'),
  ];

  String _localeName(BuildContext context, Locale locale) {
    final l = AppLocalizations.of(context)!;
    switch (locale.languageCode) {
      case 'fr':
        return l.french;
      case 'es':
        return l.spanish;
      default:
        return l.english;
    }
  }

  String _flagEmoji(String code) {
    switch (code) {
      case 'fr':
        return '\u{1F1EB}\u{1F1F7}';
      case 'es':
        return '\u{1F1EA}\u{1F1F8}';
      default:
        return '\u{1F1EC}\u{1F1E7}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final current = context.watch<LanguageProvider>().locale;

    return ListTile(
      leading: PhosphorIcon(PhosphorIconsLight.translate,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      title: Text(
        l.language,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        _localeName(context, current),
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      onTap: () => _showSheet(context, l, current),
    );
  }

  void _showSheet(BuildContext context, AppLocalizations l, Locale current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  l.chooseLanguage,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ..._locales.map((locale) {
                  final selected = locale.languageCode == current.languageCode;
                  return ListTile(
                    leading: Text(
                      _flagEmoji(locale.languageCode),
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      _localeName(ctx, locale),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? GameOnBrand.saffron : null,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_rounded,
                            color: GameOnBrand.saffron)
                        : null,
                    onTap: () {
                      context.read<LanguageProvider>().setLocale(locale);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Report a bug ───────────────────────────────────────────────────────────

class _ReportBugTile extends StatelessWidget {
  const _ReportBugTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final color = theme.colorScheme.onSurface;

    return ListTile(
      leading: PhosphorIcon(PhosphorIconsLight.bug,
          size: 20, color: color.withValues(alpha: 0.7)),
      title: Text(
        l.reportBug,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        l.reportBugSubtitle,
        style: TextStyle(
          fontSize: 12,
          color: color.withValues(alpha: 0.45),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 18, color: color.withValues(alpha: 0.3)),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: theme.cardTheme.color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const _BugReportSheet(),
      ),
    );
  }
}

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();

  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  final _controller = TextEditingController();
  String _category = 'bug';
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context)!;
    final description = _controller.text.trim();
    if (description.length < 10) {
      setState(() => _error = l.bugReportTooShort);
      return;
    }
    setState(() {
      _error = null;
      _isSubmitting = true;
    });
    try {
      await BugReportService()
          .submit(category: _category, description: description);
      if (!mounted) return;
      Navigator.of(context).pop();
      showSuccessSnackBar(context, l.bugReportSent);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = l.errorGeneric;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final categories = {
      'bug': l.bugTypeBug,
      'suggestion': l.bugTypeSuggestion,
      'other': l.bugTypeOther,
    };

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l.reportBug,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: categories.entries.map((e) {
              final selected = e.key == _category;
              return ChoiceChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) => setState(() => _category = e.key),
                selectedColor: GameOnBrand.saffron.withValues(alpha: 0.25),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? GameOnBrand.saffron
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: l.bugDescriptionHint,
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _send,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.send),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          PhosphorIcon(icon, size: 15, color: GameOnBrand.saffron),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: GameOnBrand.saffron,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'GameOn v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : 'GameOn';
        return Center(
          child: Text(
            version,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final color = theme.colorScheme.onSurface;

    return ListTile(
      leading: PhosphorIcon(PhosphorIconsLight.signOut,
          size: 20, color: color.withValues(alpha: 0.7)),
      title: Text(
        l.signOutConfirm,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 14,
        ),
      ),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(l.signOut),
            content: Text(l.signOutBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: Text(l.signOutConfirm),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) GoRouter.of(context).go('/login');
        }
      },
    );
  }
}

class _DeleteAccountTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return ListTile(
      leading: PhosphorIcon(PhosphorIconsLight.trash,
          size: 20, color: Colors.redAccent.withValues(alpha: 0.7)),
      title: Text(
        l.deleteAccount,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        l.deleteAccountSubtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
      onTap: () => _showDeleteAccountDialog(context),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(l.deleteAccountTitle),
          content: const _DeleteAccountDialogContent(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.cancel),
            ),
          ],
        );
      },
    );
  }
}

class _DeleteAccountDialogContent extends StatefulWidget {
  const _DeleteAccountDialogContent();

  @override
  State<_DeleteAccountDialogContent> createState() =>
      _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState
    extends State<_DeleteAccountDialogContent> {
  final _controller = TextEditingController();
  bool _canDelete = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.deleteAccountWarning,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l.typeDeleteToConfirm,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: (v) {
            final match = v.trim().toUpperCase() == 'DELETE';
            if (match != _canDelete) {
              setState(() => _canDelete = match);
            }
          },
          decoration: const InputDecoration(hintText: 'DELETE'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canDelete && !_isDeleting
                ? () async {
                    setState(() => _isDeleting = true);
                    final auth = context.read<AuthProvider>();
                    final success = await auth.deleteAccount();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // close dialog
                    if (success) {
                      GoRouter.of(context).go('/login');
                    }
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
            ),
            child: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l.deleteAccountTitle),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }
}
