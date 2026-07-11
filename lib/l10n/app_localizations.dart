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

  /// No description provided for @createMatch.
  ///
  /// In en, this message translates to:
  /// **'Create a Match'**
  String get createMatch;

  /// No description provided for @widenFilters.
  ///
  /// In en, this message translates to:
  /// **'Try widening your date filter'**
  String get widenFilters;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'or join a group to see more'**
  String get joinGroup;

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

  /// No description provided for @genderRestriction.
  ///
  /// In en, this message translates to:
  /// **'Who can join'**
  String get genderRestriction;

  /// No description provided for @genderRestrictionHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for everyone'**
  String get genderRestrictionHint;

  /// No description provided for @openToAllGenders.
  ///
  /// In en, this message translates to:
  /// **'Open to all genders'**
  String get openToAllGenders;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a password reset link has been sent.'**
  String get resetPasswordSent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account, matches, and all associated data. This action cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm:'**
  String get typeDeleteToConfirm;

  /// No description provided for @legalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAcceptThe;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andThe.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get andThe;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @chooseAppearance.
  ///
  /// In en, this message translates to:
  /// **'Choose Appearance'**
  String get chooseAppearance;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @phoneSaved.
  ///
  /// In en, this message translates to:
  /// **'Phone number saved'**
  String get phoneSaved;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @errorAlreadyJoined.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in this match'**
  String get errorAlreadyJoined;

  /// No description provided for @errorMatchFull.
  ///
  /// In en, this message translates to:
  /// **'This match is full'**
  String get errorMatchFull;

  /// No description provided for @errorCouldNotJoin.
  ///
  /// In en, this message translates to:
  /// **'Could not join match'**
  String get errorCouldNotJoin;

  /// No description provided for @errorCouldNotLeave.
  ///
  /// In en, this message translates to:
  /// **'Could not leave match'**
  String get errorCouldNotLeave;

  /// No description provided for @errorCouldNotCreate.
  ///
  /// In en, this message translates to:
  /// **'Could not create match'**
  String get errorCouldNotCreate;

  /// No description provided for @errorCouldNotConfirm.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm match'**
  String get errorCouldNotConfirm;

  /// No description provided for @errorInvalidClaimCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code or spot already taken'**
  String get errorInvalidClaimCode;

  /// No description provided for @errorCouldNotAddGuests.
  ///
  /// In en, this message translates to:
  /// **'Could not add guests'**
  String get errorCouldNotAddGuests;

  /// No description provided for @errorCouldNotLoadMatches.
  ///
  /// In en, this message translates to:
  /// **'Could not load matches'**
  String get errorCouldNotLoadMatches;

  /// No description provided for @errorCouldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get errorCouldNotLoadProfile;

  /// No description provided for @errorCouldNotSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile'**
  String get errorCouldNotSaveProfile;

  /// No description provided for @errorCouldNotUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo'**
  String get errorCouldNotUploadPhoto;

  /// No description provided for @errorCouldNotCompleteSetup.
  ///
  /// In en, this message translates to:
  /// **'Could not complete setup'**
  String get errorCouldNotCompleteSetup;

  /// No description provided for @errorCouldNotSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not save location'**
  String get errorCouldNotSaveLocation;

  /// No description provided for @errorCouldNotLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups'**
  String get errorCouldNotLoadGroups;

  /// No description provided for @errorCouldNotCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not create group'**
  String get errorCouldNotCreateGroup;

  /// No description provided for @errorCouldNotJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not join group'**
  String get errorCouldNotJoinGroup;

  /// No description provided for @errorCouldNotLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not leave group'**
  String get errorCouldNotLeaveGroup;

  /// No description provided for @errorInvalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code'**
  String get errorInvalidInviteCode;

  /// No description provided for @errorCouldNotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account'**
  String get errorCouldNotDeleteAccount;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email'**
  String get errorEmailTaken;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @genderRestrictionMustIncludeSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t exclude your own gender from a match you create'**
  String get genderRestrictionMustIncludeSelf;

  /// No description provided for @genderRestrictionSetGenderFirst.
  ///
  /// In en, this message translates to:
  /// **'Set your gender in your profile to restrict a match'**
  String get genderRestrictionSetGenderFirst;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// No description provided for @reportBugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something broken? Tell us'**
  String get reportBugSubtitle;

  /// No description provided for @bugTypeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get bugTypeBug;

  /// No description provided for @bugTypeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get bugTypeSuggestion;

  /// No description provided for @bugTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get bugTypeOther;

  /// No description provided for @bugDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened…'**
  String get bugDescriptionHint;

  /// No description provided for @bugReportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your report was sent.'**
  String get bugReportSent;

  /// No description provided for @bugReportTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please give a bit more detail (min 10 characters)'**
  String get bugReportTooShort;

  /// No description provided for @guestNumber.
  ///
  /// In en, this message translates to:
  /// **'Guest {number}'**
  String guestNumber(int number);

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayersYet;

  /// No description provided for @unclaimedSpot.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed spot'**
  String get unclaimedSpot;

  /// No description provided for @addGuest.
  ///
  /// In en, this message translates to:
  /// **'Add guest'**
  String get addGuest;

  /// No description provided for @guestClaimCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'We\'ll generate a claim code for each guest slot.'**
  String get guestClaimCodeInfo;

  /// No description provided for @removeGuestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove guest?'**
  String get removeGuestQuestion;

  /// No description provided for @removeGuestBody.
  ///
  /// In en, this message translates to:
  /// **'This guest slot will be freed up.'**
  String get removeGuestBody;

  /// No description provided for @matchCancelledBanner.
  ///
  /// In en, this message translates to:
  /// **'Match cancelled'**
  String get matchCancelledBanner;

  /// No description provided for @cancelledBadge.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledBadge;

  /// No description provided for @matchIsFull.
  ///
  /// In en, this message translates to:
  /// **'Match is full'**
  String get matchIsFull;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @shareInviteText.
  ///
  /// In en, this message translates to:
  /// **'🎮 You\'ve been invited to a GameOn match!\n\nHave the app? Open your spot:\n{deepLink}\n\nManual code: {code}'**
  String shareInviteText(String deepLink, String code);

  /// No description provided for @shareInviteSubject.
  ///
  /// In en, this message translates to:
  /// **'Join my GameOn match'**
  String get shareInviteSubject;

  /// No description provided for @inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite copied to clipboard'**
  String get inviteCopied;

  /// No description provided for @joinBringFriendsInfo.
  ///
  /// In en, this message translates to:
  /// **'Bring friends along — we\'ll generate a code for each guest slot.'**
  String get joinBringFriendsInfo;

  /// No description provided for @addGuestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 guest} other{Add {count} guests}}'**
  String addGuestsCount(int count);

  /// No description provided for @unlimitedSpots.
  ///
  /// In en, this message translates to:
  /// **'Unlimited spots'**
  String get unlimitedSpots;

  /// No description provided for @unlimitedSpotsHint.
  ///
  /// In en, this message translates to:
  /// **'Anyone can join — no cap'**
  String get unlimitedSpotsHint;

  /// No description provided for @unlimitedOpenToAll.
  ///
  /// In en, this message translates to:
  /// **'Unlimited — open to all'**
  String get unlimitedOpenToAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @spotClaimed.
  ///
  /// In en, this message translates to:
  /// **'Spot claimed!'**
  String get spotClaimed;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @filterOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get filterOff;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResults;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @searchCommunityHint.
  ///
  /// In en, this message translates to:
  /// **'Search players or groups…'**
  String get searchCommunityHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @groupVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get groupVisibility;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get visibilityPrivate;

  /// No description provided for @visibilityInviteOnly.
  ///
  /// In en, this message translates to:
  /// **'On request'**
  String get visibilityInviteOnly;

  /// No description provided for @visibilityPublicDesc.
  ///
  /// In en, this message translates to:
  /// **'Anyone can find and join it'**
  String get visibilityPublicDesc;

  /// No description provided for @visibilityPrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Hidden — join with the invite code only'**
  String get visibilityPrivateDesc;

  /// No description provided for @visibilityInviteOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Visible, but joining requires approval'**
  String get visibilityInviteOnlyDesc;

  /// No description provided for @requestToJoin.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestToJoin;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join requests'**
  String get joinRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @exampleGroupName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Acme Corp Sports Club'**
  String get exampleGroupName;

  /// No description provided for @groupAboutHint.
  ///
  /// In en, this message translates to:
  /// **'What is this group about?'**
  String get groupAboutHint;

  /// No description provided for @exampleMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sunday 5-a-side'**
  String get exampleMatchTitle;

  /// No description provided for @exampleLocation.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stade Marcel Michelin, Court 3'**
  String get exampleLocation;

  /// No description provided for @exampleUsername.
  ///
  /// In en, this message translates to:
  /// **'e.g. Zidane10'**
  String get exampleUsername;

  /// No description provided for @exampleBio.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekend warrior, love 5-a-side...'**
  String get exampleBio;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username required'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Max 20 characters'**
  String get usernameTooLong;

  /// No description provided for @usernameCharset.
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, and _ only'**
  String get usernameCharset;

  /// No description provided for @guestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String guestsCount(int count);

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// No description provided for @reportMatch.
  ///
  /// In en, this message translates to:
  /// **'Report match'**
  String get reportMatch;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get unblockUser;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @blockUserBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see their matches anymore. They won\'t be notified.'**
  String get blockUserBody;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlocked;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblocked;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent. Thanks for keeping GameOn safe.'**
  String get reportSent;

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportReason;

  /// No description provided for @reasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @reasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reasonHarassment;

  /// No description provided for @reasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reasonInappropriate;

  /// No description provided for @reasonFake.
  ///
  /// In en, this message translates to:
  /// **'Fake profile'**
  String get reasonFake;

  /// No description provided for @reportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get reportDetailsHint;

  /// No description provided for @sponsored.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsored;

  /// No description provided for @spotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available spots'**
  String get spotsAvailable;

  /// No description provided for @spotsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Full} =1{1 spot left} other{{count} spots left}}'**
  String spotsRemaining(int count);
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
