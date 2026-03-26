import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
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
          _SectionHeader(label: l.notifications, icon: PhosphorIconsLight.bell),
          _PlaceholderTile(
            icon: PhosphorIconsLight.bellRinging,
            title: l.pushNotifications,
            subtitle: l.pushNotificationsSubtitle,
          ),
          _PlaceholderTile(
            icon: PhosphorIconsLight.envelope,
            title: l.emailNotifications,
            subtitle: l.emailNotificationsSubtitle,
          ),
          const _Divider(),

          _SectionHeader(label: l.account, icon: PhosphorIconsLight.user),
          _PlaceholderTile(
            icon: PhosphorIconsLight.lock,
            title: l.changePassword,
            subtitle: l.changePasswordSubtitle,
          ),
          _PlaceholderTile(
            icon: PhosphorIconsLight.phone,
            title: l.phoneNumber,
            subtitle: l.phoneNumberSubtitle,
          ),
          _PlaceholderTile(
            icon: PhosphorIconsLight.trash,
            title: l.deleteAccount,
            subtitle: l.deleteAccountSubtitle,
            destructive: true,
          ),
          const _Divider(),

          _SectionHeader(label: l.globalSection, icon: PhosphorIconsLight.globe),
          _LanguageTile(),
          _PlaceholderTile(
            icon: PhosphorIconsLight.mapPin,
            title: l.defaultLocation,
            subtitle: l.defaultLocationSubtitle,
          ),
          _PlaceholderTile(
            icon: PhosphorIconsLight.moon,
            title: l.appearance,
            subtitle: l.appearanceSubtitle,
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'GameOn v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      default:
        return '🇬🇧';
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
      backgroundColor: GameOnBrand.slateCard,
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

class _PlaceholderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;

  const _PlaceholderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? Colors.redAccent
        : theme.colorScheme.onSurface;

    return ListTile(
      leading: PhosphorIcon(icon, size: 20, color: color.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
      trailing: destructive
          ? null
          : Icon(Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      onTap: () {}, // placeholder
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
