import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/moderation_provider.dart';
import '../utils/app_snackbar.dart';

/// Opens the report bottom sheet for [reportedUserId] (optionally about a
/// specific [matchId]) and shows a snackbar with the outcome.
Future<void> showReportSheet(
  BuildContext context, {
  required String reportedUserId,
  String? matchId,
}) async {
  final l = AppLocalizations.of(context)!;
  final moderation = context.read<ModerationProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReportSheet(
      reportedUserId: reportedUserId,
      matchId: matchId,
      moderation: moderation,
    ),
  );

  if (sent == null || !context.mounted) return;
  if (sent) {
    showSuccessSnackBar(context, l.reportSent);
  } else {
    messenger.showSnackBar(SnackBar(
      content: Text(l.errorGeneric),
      backgroundColor: Colors.redAccent,
    ));
  }
}

class _ReportSheet extends StatefulWidget {
  final String reportedUserId;
  final String? matchId;
  final ModerationProvider moderation;

  const _ReportSheet({
    required this.reportedUserId,
    this.matchId,
    required this.moderation,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _detailsCtrl = TextEditingController();
  String _reason = 'spam';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _isSubmitting = true);
    final ok = await widget.moderation.reportUser(
      reportedUserId: widget.reportedUserId,
      matchId: widget.matchId,
      reason: _reason,
      details: _detailsCtrl.text.trim(),
    );
    if (mounted) Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final reasons = {
      'spam': l.reasonSpam,
      'harassment': l.reasonHarassment,
      'inappropriate': l.reasonInappropriate,
      'fake': l.reasonFake,
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
          Row(
            children: [
              const Icon(Icons.flag_rounded,
                  color: Colors.redAccent, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.matchId != null ? l.reportMatch : l.reportUser,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.reportReason.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reasons.entries.map((e) {
              final selected = e.key == _reason;
              return ChoiceChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) => setState(() => _reason = e.key),
                selectedColor: Colors.redAccent.withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.redAccent
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _detailsCtrl,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: l.reportDetailsHint,
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _send,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l.send,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
