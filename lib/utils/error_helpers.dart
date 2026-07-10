import '../l10n/app_localizations.dart';

/// Maps a provider error key to a localized user-friendly message.
///
/// Providers store short error identifiers (e.g. 'already_joined').
/// This function resolves them to the correct l10n string.
String friendlyError(String? key, AppLocalizations l10n) {
  if (key == null) return l10n.errorGeneric;
  return switch (key) {
    'already_joined'    => l10n.errorAlreadyJoined,
    'match_full'        => l10n.errorMatchFull,
    'could_not_join'    => l10n.errorCouldNotJoin,
    'could_not_leave'   => l10n.errorCouldNotLeave,
    'could_not_create'  => l10n.errorCouldNotCreate,
    'could_not_confirm' => l10n.errorCouldNotConfirm,
    'invalid_claim'     => l10n.errorInvalidClaimCode,
    'could_not_add_guests' => l10n.errorCouldNotAddGuests,
    'could_not_load_matches' => l10n.errorCouldNotLoadMatches,
    'could_not_load_profile' => l10n.errorCouldNotLoadProfile,
    'could_not_save_profile' => l10n.errorCouldNotSaveProfile,
    'could_not_upload_photo' => l10n.errorCouldNotUploadPhoto,
    'could_not_complete_setup' => l10n.errorCouldNotCompleteSetup,
    'could_not_save_location' => l10n.errorCouldNotSaveLocation,
    'could_not_load_groups' => l10n.errorCouldNotLoadGroups,
    'could_not_create_group' => l10n.errorCouldNotCreateGroup,
    'could_not_join_group' => l10n.errorCouldNotJoinGroup,
    'could_not_leave_group' => l10n.errorCouldNotLeaveGroup,
    'invalid_invite_code' => l10n.errorInvalidInviteCode,
    'could_not_delete_account' => l10n.errorCouldNotDeleteAccount,
    'invalid_credentials' => l10n.errorInvalidCredentials,
    'email_taken'       => l10n.errorEmailTaken,
    'could_not_save_availability' => l10n.couldNotSaveAvailability,
    'errorGeneric'      => l10n.errorGeneric,
    _                   => l10n.errorGeneric,
  };
}

/// Detects common Supabase/PostgreSQL error patterns and returns a clean key.
String classifyMatchError(Object e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('duplicate') || msg.contains('already')) {
    return 'already_joined';
  }
  if (msg.contains('full') || msg.contains('no spots') || msg.contains('players_needed')) {
    return 'match_full';
  }
  return 'could_not_join';
}
