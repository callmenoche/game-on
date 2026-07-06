// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GameOn';

  @override
  String get newMatch => 'Nouveau match';

  @override
  String get settings => 'Paramètres';

  @override
  String get findPlayers => 'Trouver des joueurs';

  @override
  String get searchHint => 'Rechercher par sport ou lieu…';

  @override
  String get public => 'Public';

  @override
  String get myGroups => 'Mes groupes';

  @override
  String get all => 'Tous';

  @override
  String get upcoming => 'À venir';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get next7Days => '7 jours';

  @override
  String get next30Days => '30 jours';

  @override
  String get custom => 'Personnalisé';

  @override
  String get nearby => 'À proximité';

  @override
  String distanceKm(int km) {
    return '≤ ${km}km';
  }

  @override
  String get distanceFilter => 'Filtre de distance';

  @override
  String get turnOffNearbyFilter => 'Désactiver le filtre de proximité';

  @override
  String get noMatchesFound => 'Aucun match trouvé';

  @override
  String get noUpcomingMatches => 'Aucun match à venir';

  @override
  String noMatchesWithinKm(int km) {
    return 'Aucun match à moins de ${km}km';
  }

  @override
  String noMatchesSportDate(String sport, String date) {
    return 'Aucun match de $sport$date';
  }

  @override
  String noMatchesDate(String date) {
    return 'Aucun match$date';
  }

  @override
  String get dateUpcoming => ' à venir';

  @override
  String get dateToday => ' aujourd\'hui';

  @override
  String get dateNext7 => ' dans les 7 prochains jours';

  @override
  String get dateNext30 => ' dans les 30 prochains jours';

  @override
  String get dateThisPeriod => ' sur cette période';

  @override
  String get tapToCreate => 'Appuie sur + Nouveau match pour en créer un !';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get pushNotificationsSubtitle =>
      'Rappels de matchs, demandes de rejoindre…';

  @override
  String get emailNotifications => 'Notifications e-mail';

  @override
  String get emailNotificationsSubtitle =>
      'Résumé hebdomadaire et mises à jour';

  @override
  String get account => 'Compte';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get changePasswordSubtitle => 'Mettre à jour vos identifiants';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneNumberSubtitle => 'Ajouter ou modifier votre téléphone';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountSubtitle => 'Supprimer définitivement vos données';

  @override
  String get globalSection => 'Global';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Langue d\'affichage de l\'app';

  @override
  String get defaultLocation => 'Lieu par défaut';

  @override
  String get defaultLocationSubtitle => 'Utilisé lors de la création de matchs';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceSubtitle => 'Clair, sombre ou système';

  @override
  String get profile => 'Profil';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get back => 'Retour';

  @override
  String get leave => 'Quitter';

  @override
  String get join => 'Rejoindre';

  @override
  String get full => 'Complet';

  @override
  String get openToAll => 'Ouvert à tous';

  @override
  String get confirmed => 'CONFIRMÉ';

  @override
  String get open => 'OUVERT';

  @override
  String get fullBadge => 'COMPLET';

  @override
  String get players => 'Joueurs';

  @override
  String get admin => 'Admin';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get activities => 'activités';

  @override
  String get last7Days => '7 derniers jours';

  @override
  String get topSport => 'Sport favori';

  @override
  String get noneYet => 'Aucun encore';

  @override
  String nTied(int n) {
    return '$n ex æquo';
  }

  @override
  String get activityBreakdown => 'Répartition des activités';

  @override
  String get upcomingMatches => 'Matchs à venir';

  @override
  String get recentMatches => 'Matchs récents';

  @override
  String get myAvailability => 'Ma disponibilité';

  @override
  String get weeklyAvailability => 'Disponibilité hebdomadaire';

  @override
  String get whenFreeToPlay => 'Quand êtes-vous généralement disponible ?';

  @override
  String get favouriteSports => 'Sports favoris';

  @override
  String get morning => 'Matin';

  @override
  String get afternoon => 'Après-midi';

  @override
  String get evening => 'Soir';

  @override
  String get noBioYet =>
      'Pas encore de bio — appuie sur ✏️ pour en ajouter une';

  @override
  String get bioHint => 'Une courte bio…';

  @override
  String get chooseFromLibrary => 'Choisir depuis la galerie';

  @override
  String get takeAPhoto => 'Prendre une photo';

  @override
  String get total => 'total';

  @override
  String get noMatchesScheduled => 'Aucun match planifié';

  @override
  String get noFavouritesYet =>
      'Aucun favori encore — appuie sur ✏️ pour en ajouter';

  @override
  String get signOut => 'Se déconnecter ?';

  @override
  String get signOutBody => 'Vous devrez vous reconnecter.';

  @override
  String get signOutConfirm => 'Se déconnecter';

  @override
  String get signIn => 'Connexion';

  @override
  String get signUp => 'Inscription';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get invalidEmail => 'Entrez un e-mail valide';

  @override
  String get passwordTooShort => '6 caractères minimum';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get findYourNextMatch => 'Trouve ton prochain match';

  @override
  String get welcomeToGameOn => 'Bienvenue sur GameOn !';

  @override
  String get pickSports => 'Choisis les sports que tu pratiques :';

  @override
  String get yourProfile => 'Ton profil';

  @override
  String get whatShouldWeCallYou => 'Comment doit-on t\'appeler ?';

  @override
  String get aFewWordsAboutYou => 'Quelques mots sur toi';

  @override
  String get optional => '(optionnel)';

  @override
  String get letsGo => 'C\'est parti !';

  @override
  String get myCalendar => 'Mon calendrier';

  @override
  String get feed => 'Fil';

  @override
  String get calendar => 'Calendrier';

  @override
  String get groups => 'Groupes';

  @override
  String get editMatch => 'Modifier le match';

  @override
  String get title => 'Titre';

  @override
  String get descriptionOptional => 'Description (optionnelle)';

  @override
  String get anyDetailsForPlayers => 'Détails pour les joueurs…';

  @override
  String get cancelMatch => 'Annuler le match ?';

  @override
  String get cancelMatchWarning =>
      'Tous les participants perdront leur place. Ceci ne peut pas être annulé.';

  @override
  String get keepIt => 'Garder';

  @override
  String get doCancelMatch => 'Annuler le match';

  @override
  String get unlimitedSpotsOpenToAll => 'Places illimitées — ouvert à tous';

  @override
  String spotsCount(int taken, int total) {
    return '$taken / $total joueurs';
  }

  @override
  String get host => 'Hôte';

  @override
  String get you => 'Vous';

  @override
  String get guest => 'Invité';

  @override
  String get share => 'Partager';

  @override
  String get remove => 'Retirer';

  @override
  String get claim => 'Réclamer';

  @override
  String get joinMatch => 'Rejoindre le match';

  @override
  String get leaveMatch => 'Quitter le match';

  @override
  String codeCopied(String code) {
    return 'Code copié : $code';
  }

  @override
  String get claimCode => 'Code de réclamation';

  @override
  String get enterClaimCode => 'Entrer le code de réclamation';

  @override
  String get invalidCode => 'Code invalide — vérifiez et réessayez';

  @override
  String get noGuestSpots => 'Aucune place invitée non réclamée';

  @override
  String get editTitleDescription => 'Modifier titre et description';

  @override
  String get newMatchTitle => 'Nouveau match';

  @override
  String get matchTitle => 'Titre du match';

  @override
  String get description => 'Description';

  @override
  String get sport => 'Sport';

  @override
  String get skillLevel => 'Niveau';

  @override
  String get location => 'Lieu';

  @override
  String get postTo => 'Publier dans';

  @override
  String get dateAndTime => 'Date et heure';

  @override
  String get duration => 'Durée';

  @override
  String get bringFriends => 'Amener des amis (invités)';

  @override
  String get yourLocation => 'Votre lieu';

  @override
  String get titleRequired => 'Titre requis';

  @override
  String get matchCreated => 'Match créé ! 🎉';

  @override
  String get unlimited => 'Illimité';

  @override
  String get createMatchButton => 'Créer le match';

  @override
  String get spotsLabel => 'Places';

  @override
  String get groupsTitle => 'Groupes';

  @override
  String get joinWithCode => 'Rejoindre avec un code';

  @override
  String get createGroup => 'Créer un groupe';

  @override
  String get joinAGroup => 'Rejoindre un groupe';

  @override
  String get enter8CharCode => 'Entrer le code à 8 caractères';

  @override
  String joinedGroup(String name) {
    return 'Rejoint $name ! 🎉';
  }

  @override
  String get invalidGroupCode => 'Code invalide. Vérifiez et réessayez.';

  @override
  String get noGroupsYet => 'Aucun groupe encore';

  @override
  String get noGroupsBody =>
      'Créez un groupe privé pour votre équipe ou entreprise, ou rejoignez-en un avec un code d\'invitation.';

  @override
  String get inviteCodeCopied => 'Code d\'invitation copié !';

  @override
  String get newGroup => 'Nouveau groupe';

  @override
  String get createPrivateGroup => 'Créer un groupe privé';

  @override
  String get createGroupBody =>
      'Les matchs publiés dans ce groupe ne sont visibles que par les membres. Partagez le code d\'invitation pour agrandir votre groupe.';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get couldNotCreateGroup => 'Impossible de créer le groupe. Réessayez.';

  @override
  String get inviteCode => 'Code d\'invitation';

  @override
  String get shareCodeToJoin =>
      'Partagez ce code pour que d\'autres puissent rejoindre';

  @override
  String get codeCopiedToClipboard => 'Code copié dans le presse-papiers !';

  @override
  String get members => 'Membres';

  @override
  String get leaveGroup => 'Quitter le groupe';

  @override
  String get leaveGroupBody =>
      'Vous ne verrez plus les matchs privés de ce groupe.';

  @override
  String get searchPlayersHint => 'Rechercher des joueurs par pseudo…';

  @override
  String get searchForPlayers => 'Rechercher des joueurs par pseudo';

  @override
  String noPlayersFound(String query) {
    return 'Aucun joueur trouvé pour « $query »';
  }

  @override
  String get player => 'Joueur';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get noNotificationsYet => 'Aucune notification encore';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int n) {
    return 'il y a ${n}min';
  }

  @override
  String hoursAgo(int n) {
    return 'il y a ${n}h';
  }

  @override
  String daysAgo(int n) {
    return 'il y a ${n}j';
  }

  @override
  String get sportFootball => 'Football';

  @override
  String get sportPadel => 'Padel';

  @override
  String get sportRunning => 'Course';

  @override
  String get sportBasketball => 'Basketball';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportCycling => 'Cyclisme';

  @override
  String get sportOther => 'Autre';

  @override
  String get skillAllLevels => 'Tous niveaux';

  @override
  String get skillBeginner => 'Débutant';

  @override
  String get skillIntermediate => 'Intermédiaire';

  @override
  String get skillExpert => 'Expert';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Español';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get almostThere => 'Presque prêt !';

  @override
  String get optionalInfoSubtitle => 'Optionnel — modifiable plus tard';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get gender => 'Genre';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get nonBinary => 'Non-binaire';

  @override
  String get privacySection => 'Confidentialité';

  @override
  String get showAgeOnProfile => 'Afficher l\'âge sur le profil';

  @override
  String get showGenderOnProfile => 'Afficher le genre sur le profil';

  @override
  String get connectionLost => 'Pas de connexion internet';

  @override
  String get connectionRestored => 'Connexion rétablie';

  @override
  String get couldNotSaveAvailability =>
      'Impossible de sauvegarder la disponibilité';

  @override
  String get couldNotSaveProfile => 'Impossible de sauvegarder le profil';

  @override
  String get couldNotLeaveMatch => 'Impossible de quitter le match';

  @override
  String get couldNotConfirmMatch => 'Impossible de confirmer le match';

  @override
  String get leaveMatchQuestion => 'Quitter le match ?';

  @override
  String get leaveMatchBody => 'Vous perdrez votre place dans ce match.';

  @override
  String get matchNotFound => 'Ce match n\'existe plus';

  @override
  String get locationRequired => 'Le lieu est obligatoire';

  @override
  String get dateInPast => 'La date du match doit être dans le futur';

  @override
  String get usernameTaken => 'Ce pseudo est déjà pris';

  @override
  String get checkingUsername => 'Vérification…';

  @override
  String get usernameAvailable => 'Pseudo disponible';

  @override
  String get next => 'Suivant →';

  @override
  String get somethingWentWrong => 'Un problème est survenu';

  @override
  String get retry => 'Réessayer';

  @override
  String get noMatchesYet => 'Aucun match encore';

  @override
  String get createOrJoin => 'Crée un match ou rejoins-en un depuis le fil !';
}
