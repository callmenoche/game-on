import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GameOn'**
  String get appTitle;

  /// No description provided for @newMatch.
  ///
  /// In en, this message translates to:
  /// **'New Match'**
  String get newMatch;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @findPlayers.
  ///
  /// In en, this message translates to:
  /// **'Find players'**
  String get findPlayers;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by sport or location…'**
  String get searchHint;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @next7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get next7Days;

  /// No description provided for @next30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get next30Days;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'≤ {km}km'**
  String distanceKm(int km);

  /// No description provided for @distanceFilter.
  ///
  /// In en, this message translates to:
  /// **'Distance filter'**
  String get distanceFilter;

  /// No description provided for @turnOffNearbyFilter.
  ///
  /// In en, this message translates to:
  /// **'Turn off nearby filter'**
  String get turnOffNearbyFilter;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// No description provided for @noUpcomingMatches.
  ///
  /// In en, this message translates to:
  /// **'No upcoming matches'**
  String get noUpcomingMatches;

  /// No description provided for @noMatchesWithinKm.
  ///
  /// In en, this message translates to:
  /// **'No matches within {km}km'**
  String noMatchesWithinKm(int km);

  /// No description provided for @noMatchesSportDate.
  ///
  /// In en, this message translates to:
  /// **'No {sport} matches{date}'**
  String noMatchesSportDate(String sport, String date);

  /// No description provided for @noMatchesDate.
  ///
  /// In en, this message translates to:
  /// **'No matches{date}'**
  String noMatchesDate(String date);

  /// No description provided for @dateUpcoming.
  ///
  /// In en, this message translates to:
  /// **' upcoming'**
  String get dateUpcoming;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **' today'**
  String get dateToday;

  /// No description provided for @dateNext7.
  ///
  /// In en, this message translates to:
  /// **' in the next 7 days'**
  String get dateNext7;

  /// No description provided for @dateNext30.
  ///
  /// In en, this message translates to:
  /// **' in the next 30 days'**
  String get dateNext30;

  /// No description provided for @dateThisPeriod.
  ///
  /// In en, this message translates to:
  /// **' in this period'**
  String get dateThisPeriod;

  /// No description provided for @tapToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap + New Match to create one!'**
  String get tapToCreate;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match reminders, join requests…'**
  String get pushNotificationsSubtitle;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly digest and updates'**
  String get emailNotificationsSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your login credentials'**
  String get changePasswordSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add or change your phone'**
  String get phoneNumberSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your data'**
  String get deleteAccountSubtitle;

  /// No description provided for @globalSection.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get globalSection;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get languageSubtitle;

  /// No description provided for @defaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Default location'**
  String get defaultLocation;

  /// No description provided for @defaultLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used when creating matches'**
  String get defaultLocationSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, dark or system default'**
  String get appearanceSubtitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @openToAll.
  ///
  /// In en, this message translates to:
  /// **'Open to all'**
  String get openToAll;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get confirmed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get open;

  /// No description provided for @fullBadge.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get fullBadge;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'activities'**
  String get activities;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @topSport.
  ///
  /// In en, this message translates to:
  /// **'Top sport'**
  String get topSport;

  /// No description provided for @noneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get noneYet;

  /// Label shown when n sports are equally top-ranked
  ///
  /// In en, this message translates to:
  /// **'{n} tied'**
  String nTied(int n);

  /// No description provided for @activityBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Activity Breakdown'**
  String get activityBreakdown;

  /// No description provided for @upcomingMatches.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Matches'**
  String get upcomingMatches;

  /// No description provided for @recentMatches.
  ///
  /// In en, this message translates to:
  /// **'Recent Matches'**
  String get recentMatches;

  /// No description provided for @myAvailability.
  ///
  /// In en, this message translates to:
  /// **'My Availability'**
  String get myAvailability;

  /// No description provided for @weeklyAvailability.
  ///
  /// In en, this message translates to:
  /// **'Weekly Availability'**
  String get weeklyAvailability;

  /// No description provided for @whenFreeToPlay.
  ///
  /// In en, this message translates to:
  /// **'When are you usually free to play?'**
  String get whenFreeToPlay;

  /// No description provided for @favouriteSports.
  ///
  /// In en, this message translates to:
  /// **'Favourite Sports'**
  String get favouriteSports;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @noBioYet.
  ///
  /// In en, this message translates to:
  /// **'No bio yet — tap ✏️ to add one'**
  String get noBioYet;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'A short bio…'**
  String get bioHint;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @noMatchesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled'**
  String get noMatchesScheduled;

  /// No description provided for @noFavouritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet — tap ✏️ to add'**
  String get noFavouritesYet;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOut;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again.'**
  String get signOutBody;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirm;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordTooShort;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @findYourNextMatch.
  ///
  /// In en, this message translates to:
  /// **'Find your next match'**
  String get findYourNextMatch;

  /// No description provided for @welcomeToGameOn.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GameOn!'**
  String get welcomeToGameOn;

  /// No description provided for @pickSports.
  ///
  /// In en, this message translates to:
  /// **'Pick the sports you play:'**
  String get pickSports;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @whatShouldWeCallYou.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get whatShouldWeCallYou;

  /// No description provided for @aFewWordsAboutYou.
  ///
  /// In en, this message translates to:
  /// **'A few words about you'**
  String get aFewWordsAboutYou;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get letsGo;

  /// No description provided for @myCalendar.
  ///
  /// In en, this message translates to:
  /// **'My Calendar'**
  String get myCalendar;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @editMatch.
  ///
  /// In en, this message translates to:
  /// **'Edit match'**
  String get editMatch;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @anyDetailsForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Any details for players…'**
  String get anyDetailsForPlayers;

  /// No description provided for @cancelMatch.
  ///
  /// In en, this message translates to:
  /// **'Cancel match?'**
  String get cancelMatch;

  /// No description provided for @cancelMatchWarning.
  ///
  /// In en, this message translates to:
  /// **'All participants will lose their spot. This cannot be undone.'**
  String get cancelMatchWarning;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @doCancelMatch.
  ///
  /// In en, this message translates to:
  /// **'Cancel match'**
  String get doCancelMatch;

  /// No description provided for @unlimitedSpotsOpenToAll.
  ///
  /// In en, this message translates to:
  /// **'Unlimited spots — open to all'**
  String get unlimitedSpotsOpenToAll;

  /// No description provided for @spotsCount.
  ///
  /// In en, this message translates to:
  /// **'{taken} / {total} players'**
  String spotsCount(int taken, int total);

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @joinMatch.
  ///
  /// In en, this message translates to:
  /// **'Join Match'**
  String get joinMatch;

  /// No description provided for @leaveMatch.
  ///
  /// In en, this message translates to:
  /// **'Leave Match'**
  String get leaveMatch;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied: {code}'**
  String codeCopied(String code);

  /// No description provided for @claimCode.
  ///
  /// In en, this message translates to:
  /// **'Claim Code'**
  String get claimCode;

  /// No description provided for @enterClaimCode.
  ///
  /// In en, this message translates to:
  /// **'Enter claim code'**
  String get enterClaimCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code — check and try again'**
  String get invalidCode;

  /// No description provided for @noGuestSpots.
  ///
  /// In en, this message translates to:
  /// **'No unclaimed guest spots'**
  String get noGuestSpots;

  /// No description provided for @editTitleDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit title & description'**
  String get editTitleDescription;

  /// No description provided for @newMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'New Match'**
  String get newMatchTitle;

  /// No description provided for @matchTitle.
  ///
  /// In en, this message translates to:
  /// **'Match title'**
  String get matchTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @skillLevel.
  ///
  /// In en, this message translates to:
  /// **'Skill level'**
  String get skillLevel;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @postTo.
  ///
  /// In en, this message translates to:
  /// **'Post to'**
  String get postTo;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @bringFriends.
  ///
  /// In en, this message translates to:
  /// **'Bring friends (guests)'**
  String get bringFriends;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title required'**
  String get titleRequired;

  /// No description provided for @matchCreated.
  ///
  /// In en, this message translates to:
  /// **'Match created! 🎉'**
  String get matchCreated;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @createMatchButton.
  ///
  /// In en, this message translates to:
  /// **'Create Match'**
  String get createMatchButton;

  /// No description provided for @spotsLabel.
  ///
  /// In en, this message translates to:
  /// **'Spots'**
  String get spotsLabel;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @joinAGroup.
  ///
  /// In en, this message translates to:
  /// **'Join a Group'**
  String get joinAGroup;

  /// No description provided for @enter8CharCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 8-character code'**
  String get enter8CharCode;

  /// No description provided for @joinedGroup.
  ///
  /// In en, this message translates to:
  /// **'Joined {name}! 🎉'**
  String joinedGroup(String name);

  /// No description provided for @invalidGroupCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Check and try again.'**
  String get invalidGroupCode;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsYet;

  /// No description provided for @noGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a private group for your team or company, or join one with an invite code.'**
  String get noGroupsBody;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied!'**
  String get inviteCodeCopied;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @createPrivateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create a private group'**
  String get createPrivateGroup;

  /// No description provided for @createGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Matches posted to this group are only visible to members. Share the invite code to grow your group.'**
  String get createGroupBody;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @couldNotCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not create group. Try again.'**
  String get couldNotCreateGroup;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCode;

  /// No description provided for @shareCodeToJoin.
  ///
  /// In en, this message translates to:
  /// **'Share this code so others can join'**
  String get shareCodeToJoin;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopiedToClipboard;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupBody.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see private matches from this group.'**
  String get leaveGroupBody;

  /// No description provided for @searchPlayersHint.
  ///
  /// In en, this message translates to:
  /// **'Search players by username…'**
  String get searchPlayersHint;

  /// No description provided for @searchForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Search for players by username'**
  String get searchForPlayers;

  /// No description provided for @noPlayersFound.
  ///
  /// In en, this message translates to:
  /// **'No players found for \"{query}\"'**
  String noPlayersFound(String query);

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String daysAgo(int n);

  /// No description provided for @sportFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get sportFootball;

  /// No description provided for @sportPadel.
  ///
  /// In en, this message translates to:
  /// **'Padel'**
  String get sportPadel;

  /// No description provided for @sportRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sportRunning;

  /// No description provided for @sportBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get sportBasketball;

  /// No description provided for @sportTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get sportTennis;

  /// No description provided for @sportCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get sportCycling;

  /// No description provided for @sportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sportOther;

  /// No description provided for @skillAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get skillAllLevels;

  /// No description provided for @skillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get skillBeginner;

  /// No description provided for @skillIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get skillIntermediate;

  /// No description provided for @skillExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get skillExpert;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @optionalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — you can change this later'**
  String get optionalInfoSubtitle;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get female;

  /// No description provided for @nonBinary.
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get nonBinary;

  /// No description provided for @privacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySection;

  /// No description provided for @showAgeOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show age on profile'**
  String get showAgeOnProfile;

  /// No description provided for @showGenderOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show gender on profile'**
  String get showGenderOnProfile;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get connectionLost;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get connectionRestored;

  /// No description provided for @couldNotSaveAvailability.
  ///
  /// In en, this message translates to:
  /// **'Could not save availability'**
  String get couldNotSaveAvailability;

  /// No description provided for @couldNotSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile'**
  String get couldNotSaveProfile;

  /// No description provided for @couldNotLeaveMatch.
  ///
  /// In en, this message translates to:
  /// **'Could not leave match'**
  String get couldNotLeaveMatch;

  /// No description provided for @couldNotConfirmMatch.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm match'**
  String get couldNotConfirmMatch;

  /// No description provided for @leaveMatchQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave match?'**
  String get leaveMatchQuestion;

  /// No description provided for @leaveMatchBody.
  ///
  /// In en, this message translates to:
  /// **'You will lose your spot in this match.'**
  String get leaveMatchBody;

  /// No description provided for @matchNotFound.
  ///
  /// In en, this message translates to:
  /// **'This match no longer exists'**
  String get matchNotFound;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// No description provided for @dateInPast.
  ///
  /// In en, this message translates to:
  /// **'Match date must be in the future'**
  String get dateInPast;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get usernameTaken;

  /// No description provided for @checkingUsername.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checkingUsername;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username available'**
  String get usernameAvailable;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get next;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatchesYet;

  /// No description provided for @createOrJoin.
  ///
  /// In en, this message translates to:
  /// **'Create a match or join one from the feed!'**
  String get createOrJoin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
