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
}
