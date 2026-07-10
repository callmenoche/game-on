import 'package:flutter/material.dart';
import '../legal/legal_content.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_on_logo.dart';

class LegalScreen extends StatelessWidget {
  final LegalPageType type;
  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final doc = (legalContent[lang] ?? legalContent['en']!)[type]!;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.lastUpdated(doc.lastUpdated),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            for (final section in doc.sections) ...[
              Text(
                section.heading,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: GameOnBrand.saffron,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
