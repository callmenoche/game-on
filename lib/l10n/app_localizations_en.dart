// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GameOn';

  @override
  String get newMatch => 'New Match';

  @override
  String get settings => 'Settings';

  @override
  String get findPlayers => 'Find players';

  @override
  String get searchHint => 'Search by sport or location…';

  @override
  String get public => 'Public';

  @override
  String get myGroups => 'My Groups';

  @override
  String get all => 'All';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get today => 'Today';

  @override
  String get next7Days => '7 days';

  @override
  String get next30Days => '30 days';

  @override
  String get custom => 'Custom';

  @override
  String get nearby => 'Nearby';

  @override
  String distanceKm(int km) {
    return '≤ ${km}km';
  }

  @override
  String get distanceFilter => 'Distance filter';

  @override
  String get turnOffNearbyFilter => 'Turn off nearby filter';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String get noUpcomingMatches => 'No upcoming matches';

  @override
  String noMatchesWithinKm(int km) {
    return 'No matches within ${km}km';
  }

  @override
  String noMatchesSportDate(String sport, String date) {
    return 'No $sport matches$date';
  }

  @override
  String noMatchesDate(String date) {
    return 'No matches$date';
  }

  @override
  String get dateUpcoming => ' upcoming';

  @override
  String get dateToday => ' today';

  @override
  String get dateNext7 => ' in the next 7 days';

  @override
  String get dateNext30 => ' in the next 30 days';

  @override
  String get dateThisPeriod => ' in this period';

  @override
  String get tapToCreate => 'Tap + New Match to create one!';

  @override
  String get createMatch => 'Create a Match';

  @override
  String get widenFilters => 'Try widening your date filter';

  @override
  String get joinGroup => 'or join a group to see more';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsSubtitle => 'Match reminders, join requests…';

  @override
  String get emailNotifications => 'Email notifications';

  @override
  String get emailNotificationsSubtitle => 'Weekly digest and updates';

  @override
  String get account => 'Account';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle => 'Update your login credentials';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberSubtitle => 'Add or change your phone';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Permanently remove your data';

  @override
  String get globalSection => 'Global';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'App display language';

  @override
  String get defaultLocation => 'Default location';

  @override
  String get defaultLocationSubtitle => 'Used when creating matches';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle => 'Light, dark or system default';

  @override
  String get profile => 'Profile';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get leave => 'Leave';

  @override
  String get join => 'Join';

  @override
  String get full => 'Full';

  @override
  String get openToAll => 'Open to all';

  @override
  String get confirmed => 'CONFIRMED';

  @override
  String get open => 'OPEN';

  @override
  String get fullBadge => 'FULL';

  @override
  String get players => 'Players';

  @override
  String get admin => 'Admin';

  @override
  String get allTime => 'All time';

  @override
  String get activities => 'activities';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get topSport => 'Top sport';

  @override
  String get noneYet => 'None yet';

  @override
  String nTied(int n) {
    return '$n tied';
  }

  @override
  String get activityBreakdown => 'Activity Breakdown';

  @override
  String get upcomingMatches => 'Upcoming Matches';

  @override
  String get recentMatches => 'Recent Matches';

  @override
  String get myAvailability => 'My Availability';

  @override
  String get weeklyAvailability => 'Weekly Availability';

  @override
  String get whenFreeToPlay => 'When are you usually free to play?';

  @override
  String get favouriteSports => 'Favourite Sports';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get noBioYet => 'No bio yet — tap ✏️ to add one';

  @override
  String get bioHint => 'A short bio…';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get total => 'total';

  @override
  String get noMatchesScheduled => 'No matches scheduled';

  @override
  String get noFavouritesYet => 'No favourites yet — tap ✏️ to add';

  @override
  String get signOut => 'Sign out?';

  @override
  String get signOutBody => 'You will need to sign in again.';

  @override
  String get signOutConfirm => 'Sign out';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Min 6 characters';

  @override
  String get createAccount => 'Create Account';

  @override
  String get findYourNextMatch => 'Find your next match';

  @override
  String get welcomeToGameOn => 'Welcome to GameOn!';

  @override
  String get pickSports => 'Pick the sports you play:';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get whatShouldWeCallYou => 'What should we call you?';

  @override
  String get aFewWordsAboutYou => 'A few words about you';

  @override
  String get optional => '(optional)';

  @override
  String get letsGo => 'Let\'s Go!';

  @override
  String get myCalendar => 'My Calendar';

  @override
  String get feed => 'Feed';

  @override
  String get calendar => 'Calendar';

  @override
  String get groups => 'Groups';

  @override
  String get editMatch => 'Edit match';

  @override
  String get title => 'Title';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get anyDetailsForPlayers => 'Any details for players…';

  @override
  String get cancelMatch => 'Cancel match?';

  @override
  String get cancelMatchWarning =>
      'All participants will lose their spot. This cannot be undone.';

  @override
  String get keepIt => 'Keep it';

  @override
  String get doCancelMatch => 'Cancel match';

  @override
  String get unlimitedSpotsOpenToAll => 'Unlimited spots — open to all';

  @override
  String spotsCount(int taken, int total) {
    return '$taken / $total players';
  }

  @override
  String get host => 'Host';

  @override
  String get you => 'You';

  @override
  String get guest => 'Guest';

  @override
  String get share => 'Share';

  @override
  String get remove => 'Remove';

  @override
  String get claim => 'Claim';

  @override
  String get joinMatch => 'Join Match';

  @override
  String get leaveMatch => 'Leave Match';

  @override
  String codeCopied(String code) {
    return 'Code copied: $code';
  }

  @override
  String get claimCode => 'Claim Code';

  @override
  String get enterClaimCode => 'Enter claim code';

  @override
  String get invalidCode => 'Invalid code — check and try again';

  @override
  String get noGuestSpots => 'No unclaimed guest spots';

  @override
  String get editTitleDescription => 'Edit title & description';

  @override
  String get newMatchTitle => 'New Match';

  @override
  String get matchTitle => 'Match title';

  @override
  String get description => 'Description';

  @override
  String get sport => 'Sport';

  @override
  String get skillLevel => 'Skill level';

  @override
  String get location => 'Location';

  @override
  String get postTo => 'Post to';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get duration => 'Duration';

  @override
  String get bringFriends => 'Bring friends (guests)';

  @override
  String get yourLocation => 'Your location';

  @override
  String get titleRequired => 'Title required';

  @override
  String get matchCreated => 'Match created! 🎉';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get createMatchButton => 'Create Match';

  @override
  String get spotsLabel => 'Spots';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get joinWithCode => 'Join with code';

  @override
  String get createGroup => 'Create Group';

  @override
  String get joinAGroup => 'Join a Group';

  @override
  String get enter8CharCode => 'Enter 8-character code';

  @override
  String joinedGroup(String name) {
    return 'Joined $name! 🎉';
  }

  @override
  String get invalidGroupCode => 'Invalid code. Check and try again.';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get noGroupsBody =>
      'Create a private group for your team or company, or join one with an invite code.';

  @override
  String get inviteCodeCopied => 'Invite code copied!';

  @override
  String get newGroup => 'New Group';

  @override
  String get createPrivateGroup => 'Create a private group';

  @override
  String get createGroupBody =>
      'Matches posted to this group are only visible to members. Share the invite code to grow your group.';

  @override
  String get groupName => 'Group name';

  @override
  String get couldNotCreateGroup => 'Could not create group. Try again.';

  @override
  String get inviteCode => 'Invite Code';

  @override
  String get shareCodeToJoin => 'Share this code so others can join';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard!';

  @override
  String get members => 'Members';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get leaveGroupBody =>
      'You will no longer see private matches from this group.';

  @override
  String get searchPlayersHint => 'Search players by username…';

  @override
  String get searchForPlayers => 'Search for players by username';

  @override
  String noPlayersFound(String query) {
    return 'No players found for \"$query\"';
  }

  @override
  String get player => 'Player';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int n) {
    return '${n}m ago';
  }

  @override
  String hoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String daysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String get sportFootball => 'Football';

  @override
  String get sportPadel => 'Padel';

  @override
  String get sportRunning => 'Running';

  @override
  String get sportBasketball => 'Basketball';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportCycling => 'Cycling';

  @override
  String get sportOther => 'Other';

  @override
  String get skillAllLevels => 'All levels';

  @override
  String get skillBeginner => 'Beginner';

  @override
  String get skillIntermediate => 'Intermediate';

  @override
  String get skillExpert => 'Expert';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Español';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get optionalInfoSubtitle => 'Optional — you can change this later';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get selectDate => 'Select date';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Man';

  @override
  String get female => 'Woman';

  @override
  String get nonBinary => 'Non-binary';

  @override
  String get privacySection => 'Privacy';

  @override
  String get showAgeOnProfile => 'Show age on profile';

  @override
  String get showGenderOnProfile => 'Show gender on profile';

  @override
  String get connectionLost => 'No internet connection';

  @override
  String get connectionRestored => 'Back online';

  @override
  String get couldNotSaveAvailability => 'Could not save availability';

  @override
  String get couldNotSaveProfile => 'Could not save profile';

  @override
  String get couldNotLeaveMatch => 'Could not leave match';

  @override
  String get couldNotConfirmMatch => 'Could not confirm match';

  @override
  String get leaveMatchQuestion => 'Leave match?';

  @override
  String get leaveMatchBody => 'You will lose your spot in this match.';

  @override
  String get matchNotFound => 'This match no longer exists';

  @override
  String get locationRequired => 'Location is required';

  @override
  String get dateInPast => 'Match date must be in the future';

  @override
  String get usernameTaken => 'This username is already taken';

  @override
  String get checkingUsername => 'Checking…';

  @override
  String get usernameAvailable => 'Username available';

  @override
  String get next => 'Next →';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get noMatchesYet => 'No matches yet';

  @override
  String get createOrJoin => 'Create a match or join one from the feed!';

  @override
  String get genderRestriction => 'Who can join';

  @override
  String get genderRestrictionHint => 'Leave empty for everyone';

  @override
  String get openToAllGenders => 'Open to all genders';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordSent =>
      'If an account exists for that email, a password reset link has been sent.';

  @override
  String get send => 'Send';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This will permanently delete your account, matches, and all associated data. This action cannot be undone.';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm:';

  @override
  String get legalSection => 'Legal';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get iAcceptThe => 'I accept the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andThe => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get chooseAppearance => 'Choose Appearance';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get phoneSaved => 'Phone number saved';

  @override
  String get notSet => 'Not set';

  @override
  String get errorAlreadyJoined => 'You\'re already in this match';

  @override
  String get errorMatchFull => 'This match is full';

  @override
  String get errorCouldNotJoin => 'Could not join match';

  @override
  String get errorCouldNotLeave => 'Could not leave match';

  @override
  String get errorCouldNotCreate => 'Could not create match';

  @override
  String get errorCouldNotConfirm => 'Could not confirm match';

  @override
  String get errorInvalidClaimCode => 'Invalid code or spot already taken';

  @override
  String get errorCouldNotAddGuests => 'Could not add guests';

  @override
  String get errorCouldNotLoadMatches => 'Could not load matches';

  @override
  String get errorCouldNotLoadProfile => 'Could not load profile';

  @override
  String get errorCouldNotSaveProfile => 'Could not save profile';

  @override
  String get errorCouldNotUploadPhoto => 'Could not upload photo';

  @override
  String get errorCouldNotCompleteSetup => 'Could not complete setup';

  @override
  String get errorCouldNotSaveLocation => 'Could not save location';

  @override
  String get errorCouldNotLoadGroups => 'Could not load groups';

  @override
  String get errorCouldNotCreateGroup => 'Could not create group';

  @override
  String get errorCouldNotJoinGroup => 'Could not join group';

  @override
  String get errorCouldNotLeaveGroup => 'Could not leave group';

  @override
  String get errorInvalidInviteCode => 'Invalid invite code';

  @override
  String get errorCouldNotDeleteAccount => 'Could not delete account';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorEmailTaken => 'An account already exists with this email';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get genderRestrictionMustIncludeSelf =>
      'You can\'t exclude your own gender from a match you create';

  @override
  String get genderRestrictionSetGenderFirst =>
      'Set your gender in your profile to restrict a match';

  @override
  String get supportSection => 'Support';

  @override
  String get reportBug => 'Report a bug';

  @override
  String get reportBugSubtitle => 'Something broken? Tell us';

  @override
  String get bugTypeBug => 'Bug';

  @override
  String get bugTypeSuggestion => 'Suggestion';

  @override
  String get bugTypeOther => 'Other';

  @override
  String get bugDescriptionHint => 'Describe what happened…';

  @override
  String get bugReportSent => 'Thanks! Your report was sent.';

  @override
  String get bugReportTooShort =>
      'Please give a bit more detail (min 10 characters)';

  @override
  String guestNumber(int number) {
    return 'Guest $number';
  }

  @override
  String get noPlayersYet => 'No players yet';

  @override
  String get unclaimedSpot => 'Unclaimed spot';

  @override
  String get addGuest => 'Add guest';

  @override
  String get guestClaimCodeInfo =>
      'We\'ll generate a claim code for each guest slot.';

  @override
  String get removeGuestQuestion => 'Remove guest?';

  @override
  String get removeGuestBody => 'This guest slot will be freed up.';

  @override
  String get matchCancelledBanner => 'Match cancelled';

  @override
  String get cancelledBadge => 'CANCELLED';

  @override
  String get matchIsFull => 'Match is full';

  @override
  String get selectTime => 'Select time';

  @override
  String get confirm => 'Confirm';

  @override
  String shareInviteText(String deepLink, String code) {
    return '🎮 You\'ve been invited to a GameOn match!\n\nHave the app? Open your spot:\n$deepLink\n\nManual code: $code';
  }

  @override
  String get shareInviteSubject => 'Join my GameOn match';

  @override
  String get inviteCopied => 'Invite copied to clipboard';

  @override
  String get joinBringFriendsInfo =>
      'Bring friends along — we\'ll generate a code for each guest slot.';

  @override
  String addGuestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count guests',
      one: 'Add 1 guest',
    );
    return '$_temp0';
  }

  @override
  String get unlimitedSpots => 'Unlimited spots';

  @override
  String get unlimitedSpotsHint => 'Anyone can join — no cap';

  @override
  String get unlimitedOpenToAll => 'Unlimited — open to all';

  @override
  String get loading => 'Loading...';

  @override
  String get spotClaimed => 'Spot claimed!';

  @override
  String get filters => 'Filters';

  @override
  String get resetFilters => 'Reset';

  @override
  String get filterOff => 'Off';

  @override
  String get showResults => 'Show results';

  @override
  String get community => 'Community';

  @override
  String get searchCommunityHint => 'Search players or groups…';

  @override
  String get noResults => 'No results';

  @override
  String get member => 'Member';

  @override
  String get groupVisibility => 'Visibility';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get visibilityInviteOnly => 'On request';

  @override
  String get visibilityPublicDesc => 'Anyone can find and join it';

  @override
  String get visibilityPrivateDesc => 'Hidden — join with the invite code only';

  @override
  String get visibilityInviteOnlyDesc =>
      'Visible, but joining requires approval';

  @override
  String get requestToJoin => 'Request';

  @override
  String get requested => 'Requested';

  @override
  String get joinRequests => 'Join requests';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get exampleGroupName => 'e.g. Acme Corp Sports Club';

  @override
  String get groupAboutHint => 'What is this group about?';

  @override
  String get exampleMatchTitle => 'e.g. Sunday 5-a-side';

  @override
  String get exampleLocation => 'e.g. Stade Marcel Michelin, Court 3';

  @override
  String get exampleUsername => 'e.g. Zidane10';

  @override
  String get exampleBio => 'e.g. Weekend warrior, love 5-a-side...';

  @override
  String get usernameRequired => 'Username required';

  @override
  String get usernameTooShort => 'At least 3 characters';

  @override
  String get usernameTooLong => 'Max 20 characters';

  @override
  String get usernameCharset => 'Letters, numbers, and _ only';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String get reportUser => 'Report user';

  @override
  String get reportMatch => 'Report match';

  @override
  String get blockUser => 'Block user';

  @override
  String get unblockUser => 'Unblock user';

  @override
  String get block => 'Block';

  @override
  String get blockUserBody =>
      'You won\'t see their matches anymore. They won\'t be notified.';

  @override
  String get userBlocked => 'User blocked';

  @override
  String get userUnblocked => 'User unblocked';

  @override
  String get reportSent => 'Report sent. Thanks for keeping GameOn safe.';

  @override
  String get reportReason => 'Reason';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get reasonHarassment => 'Harassment';

  @override
  String get reasonInappropriate => 'Inappropriate content';

  @override
  String get reasonFake => 'Fake profile';

  @override
  String get reportDetailsHint => 'Add details (optional)';

  @override
  String get sponsored => 'Sponsored';

  @override
  String get spotsAvailable => 'Available spots';

  @override
  String spotsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots left',
      one: '1 spot left',
      zero: 'Full',
    );
    return '$_temp0';
  }
}
