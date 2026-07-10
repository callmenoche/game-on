import 'package:flutter/material.dart';

import '../widgets/game_on_logo.dart';

/// Floating success snackbar: dark card + saffron border + green check.
/// Stands out against the saffron FAB/buttons, unlike a solid saffron bar.
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GameOnBrand.slateCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: GameOnBrand.saffron.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 16, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
