import 'package:flutter_test/flutter_test.dart';
import 'package:game_on/l10n/app_localizations_en.dart';
import 'package:game_on/l10n/app_localizations_fr.dart';
import 'package:game_on/l10n/app_localizations_es.dart';
import 'package:game_on/utils/error_helpers.dart';

void main() {
  group('classifyMatchError', () {
    test('detects duplicate key (already joined)', () {
      final err = Exception(
          'duplicate key value violates unique constraint "match_participants_pkey"');
      expect(classifyMatchError(err), 'already_joined');
    });

    test('detects "already" keyword', () {
      expect(classifyMatchError(Exception('User already in match')),
          'already_joined');
    });

    test('detects match full', () {
      expect(classifyMatchError(Exception('Match is full')), 'match_full');
    });

    test('detects no spots left', () {
      expect(classifyMatchError(Exception('no spots remaining')),
          'match_full');
    });

    test('detects players_needed constraint', () {
      expect(
          classifyMatchError(
              Exception('new row violates check constraint "players_needed"')),
          'match_full');
    });

    test('returns generic join error for unknown exceptions', () {
      expect(classifyMatchError(Exception('network timeout')),
          'could_not_join');
    });
  });

  group('friendlyError — English', () {
    final l10n = AppLocalizationsEn();

    test('maps null to generic error', () {
      expect(friendlyError(null, l10n), l10n.errorGeneric);
    });

    test('maps known keys correctly', () {
      expect(friendlyError('already_joined', l10n), l10n.errorAlreadyJoined);
      expect(friendlyError('match_full', l10n), l10n.errorMatchFull);
      expect(friendlyError('could_not_join', l10n), l10n.errorCouldNotJoin);
      expect(friendlyError('could_not_leave', l10n), l10n.errorCouldNotLeave);
      expect(friendlyError('could_not_create', l10n), l10n.errorCouldNotCreate);
      expect(friendlyError('could_not_confirm', l10n), l10n.errorCouldNotConfirm);
      expect(friendlyError('invalid_claim', l10n), l10n.errorInvalidClaimCode);
      expect(friendlyError('could_not_add_guests', l10n), l10n.errorCouldNotAddGuests);
      expect(friendlyError('could_not_load_matches', l10n), l10n.errorCouldNotLoadMatches);
      expect(friendlyError('could_not_load_profile', l10n), l10n.errorCouldNotLoadProfile);
      expect(friendlyError('could_not_save_profile', l10n), l10n.errorCouldNotSaveProfile);
      expect(friendlyError('could_not_upload_photo', l10n), l10n.errorCouldNotUploadPhoto);
      expect(friendlyError('could_not_complete_setup', l10n), l10n.errorCouldNotCompleteSetup);
      expect(friendlyError('could_not_save_location', l10n), l10n.errorCouldNotSaveLocation);
      expect(friendlyError('could_not_load_groups', l10n), l10n.errorCouldNotLoadGroups);
      expect(friendlyError('could_not_create_group', l10n), l10n.errorCouldNotCreateGroup);
      expect(friendlyError('could_not_join_group', l10n), l10n.errorCouldNotJoinGroup);
      expect(friendlyError('could_not_leave_group', l10n), l10n.errorCouldNotLeaveGroup);
      expect(friendlyError('invalid_invite_code', l10n), l10n.errorInvalidInviteCode);
      expect(friendlyError('could_not_delete_account', l10n), l10n.errorCouldNotDeleteAccount);
      expect(friendlyError('invalid_credentials', l10n), l10n.errorInvalidCredentials);
      expect(friendlyError('email_taken', l10n), l10n.errorEmailTaken);
      expect(friendlyError('errorGeneric', l10n), l10n.errorGeneric);
    });

    test('maps unknown key to generic error', () {
      expect(friendlyError('totally_unknown_key', l10n), l10n.errorGeneric);
    });
  });

  group('friendlyError — French', () {
    final l10n = AppLocalizationsFr();

    test('maps keys to French strings', () {
      expect(friendlyError('already_joined', l10n),
          'Tu fais déjà partie de ce match');
      expect(friendlyError('match_full', l10n), 'Ce match est complet');
      expect(friendlyError(null, l10n), l10n.errorGeneric);
    });
  });

  group('friendlyError — Spanish', () {
    final l10n = AppLocalizationsEs();

    test('maps keys to Spanish strings', () {
      expect(friendlyError('already_joined', l10n),
          'Ya estás en este partido');
      expect(friendlyError('match_full', l10n),
          'Este partido está completo');
      expect(friendlyError(null, l10n), l10n.errorGeneric);
    });
  });
}
