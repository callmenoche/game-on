// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GameOn';

  @override
  String get newMatch => 'Nuevo partido';

  @override
  String get settings => 'Ajustes';

  @override
  String get findPlayers => 'Buscar jugadores';

  @override
  String get searchHint => 'Buscar por deporte o lugar…';

  @override
  String get public => 'Público';

  @override
  String get myGroups => 'Mis grupos';

  @override
  String get all => 'Todos';

  @override
  String get upcoming => 'Próximos';

  @override
  String get today => 'Hoy';

  @override
  String get next7Days => '7 días';

  @override
  String get next30Days => '30 días';

  @override
  String get custom => 'Personalizado';

  @override
  String get nearby => 'Cerca';

  @override
  String distanceKm(int km) {
    return '≤ ${km}km';
  }

  @override
  String get distanceFilter => 'Filtro de distancia';

  @override
  String get turnOffNearbyFilter => 'Desactivar filtro de proximidad';

  @override
  String get noMatchesFound => 'No se encontraron partidos';

  @override
  String get noUpcomingMatches => 'No hay partidos próximos';

  @override
  String noMatchesWithinKm(int km) {
    return 'No hay partidos a menos de ${km}km';
  }

  @override
  String noMatchesSportDate(String sport, String date) {
    return 'No hay partidos de $sport$date';
  }

  @override
  String noMatchesDate(String date) {
    return 'No hay partidos$date';
  }

  @override
  String get dateUpcoming => ' próximos';

  @override
  String get dateToday => ' hoy';

  @override
  String get dateNext7 => ' en los próximos 7 días';

  @override
  String get dateNext30 => ' en los próximos 30 días';

  @override
  String get dateThisPeriod => ' en este período';

  @override
  String get tapToCreate => '¡Toca + Nuevo partido para crear uno!';

  @override
  String get createMatch => 'Crear un partido';

  @override
  String get widenFilters => 'Intenta ampliar tu filtro de fecha';

  @override
  String get joinGroup => 'o únete a un grupo para ver más';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get pushNotificationsSubtitle =>
      'Recordatorios de partidos, solicitudes…';

  @override
  String get emailNotifications => 'Notificaciones por correo';

  @override
  String get emailNotificationsSubtitle => 'Resumen semanal y actualizaciones';

  @override
  String get account => 'Cuenta';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get changePasswordSubtitle => 'Actualizar tus credenciales';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get phoneNumberSubtitle => 'Añadir o cambiar tu teléfono';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountSubtitle => 'Eliminar permanentemente tus datos';

  @override
  String get globalSection => 'Global';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Idioma de la aplicación';

  @override
  String get defaultLocation => 'Ubicación predeterminada';

  @override
  String get defaultLocationSubtitle => 'Usada al crear partidos';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSubtitle => 'Claro, oscuro o predeterminado del sistema';

  @override
  String get profile => 'Perfil';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get back => 'Atrás';

  @override
  String get leave => 'Salir';

  @override
  String get join => 'Unirse';

  @override
  String get full => 'Completo';

  @override
  String get openToAll => 'Abierto a todos';

  @override
  String get confirmed => 'CONFIRMADO';

  @override
  String get open => 'ABIERTO';

  @override
  String get fullBadge => 'COMPLETO';

  @override
  String get players => 'Jugadores';

  @override
  String get admin => 'Admin';

  @override
  String get allTime => 'Total';

  @override
  String get activities => 'actividades';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get topSport => 'Deporte favorito';

  @override
  String get noneYet => 'Ninguno aún';

  @override
  String nTied(int n) {
    return '$n empatados';
  }

  @override
  String get activityBreakdown => 'Desglose de actividad';

  @override
  String get upcomingMatches => 'Partidos próximos';

  @override
  String get recentMatches => 'Partidos recientes';

  @override
  String get myAvailability => 'Mi disponibilidad';

  @override
  String get weeklyAvailability => 'Disponibilidad semanal';

  @override
  String get whenFreeToPlay => '¿Cuándo sueles estar libre para jugar?';

  @override
  String get favouriteSports => 'Deportes favoritos';

  @override
  String get morning => 'Mañana';

  @override
  String get afternoon => 'Tarde';

  @override
  String get evening => 'Noche';

  @override
  String get noBioYet => 'Sin bio aún — toca ✏️ para añadir una';

  @override
  String get bioHint => 'Una breve bio…';

  @override
  String get chooseFromLibrary => 'Elegir de la galería';

  @override
  String get takeAPhoto => 'Tomar una foto';

  @override
  String get total => 'total';

  @override
  String get noMatchesScheduled => 'No hay partidos programados';

  @override
  String get noFavouritesYet => 'Sin favoritos aún — toca ✏️ para añadir';

  @override
  String get signOut => '¿Cerrar sesión?';

  @override
  String get signOutBody => 'Tendrás que iniciar sesión de nuevo.';

  @override
  String get signOutConfirm => 'Cerrar sesión';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get invalidEmail => 'Introduce un correo válido';

  @override
  String get passwordTooShort => 'Mín. 6 caracteres';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get findYourNextMatch => 'Encuentra tu próximo partido';

  @override
  String get welcomeToGameOn => '¡Bienvenido a GameOn!';

  @override
  String get pickSports => 'Elige los deportes que practicas:';

  @override
  String get yourProfile => 'Tu perfil';

  @override
  String get whatShouldWeCallYou => '¿Cómo debemos llamarte?';

  @override
  String get aFewWordsAboutYou => 'Unas palabras sobre ti';

  @override
  String get optional => '(opcional)';

  @override
  String get letsGo => '¡Vamos!';

  @override
  String get myCalendar => 'Mi calendario';

  @override
  String get feed => 'Inicio';

  @override
  String get calendar => 'Calendario';

  @override
  String get groups => 'Grupos';

  @override
  String get editMatch => 'Editar partido';

  @override
  String get title => 'Título';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get anyDetailsForPlayers => 'Detalles para los jugadores…';

  @override
  String get cancelMatch => '¿Cancelar partido?';

  @override
  String get cancelMatchWarning =>
      'Todos los participantes perderán su lugar. Esto no se puede deshacer.';

  @override
  String get keepIt => 'Mantener';

  @override
  String get doCancelMatch => 'Cancelar partido';

  @override
  String get unlimitedSpotsOpenToAll => 'Plazas ilimitadas — abierto a todos';

  @override
  String spotsCount(int taken, int total) {
    return '$taken / $total jugadores';
  }

  @override
  String get host => 'Anfitrión';

  @override
  String get you => 'Tú';

  @override
  String get guest => 'Invitado';

  @override
  String get share => 'Compartir';

  @override
  String get remove => 'Eliminar';

  @override
  String get claim => 'Reclamar';

  @override
  String get joinMatch => 'Unirse al partido';

  @override
  String get leaveMatch => 'Salir del partido';

  @override
  String codeCopied(String code) {
    return 'Código copiado: $code';
  }

  @override
  String get claimCode => 'Código de reclamación';

  @override
  String get enterClaimCode => 'Introduce el código de reclamación';

  @override
  String get invalidCode => 'Código inválido — comprueba e inténtalo de nuevo';

  @override
  String get noGuestSpots => 'No hay plazas de invitado sin reclamar';

  @override
  String get editTitleDescription => 'Editar título y descripción';

  @override
  String get newMatchTitle => 'Nuevo partido';

  @override
  String get matchTitle => 'Título del partido';

  @override
  String get description => 'Descripción';

  @override
  String get sport => 'Deporte';

  @override
  String get skillLevel => 'Nivel';

  @override
  String get location => 'Lugar';

  @override
  String get postTo => 'Publicar en';

  @override
  String get dateAndTime => 'Fecha y hora';

  @override
  String get duration => 'Duración';

  @override
  String get bringFriends => 'Traer amigos (invitados)';

  @override
  String get yourLocation => 'Tu lugar';

  @override
  String get titleRequired => 'Título obligatorio';

  @override
  String get matchCreated => '¡Partido creado! 🎉';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get createMatchButton => 'Crear partido';

  @override
  String get spotsLabel => 'Plazas';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get joinWithCode => 'Unirse con código';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get joinAGroup => 'Unirse a un grupo';

  @override
  String get enter8CharCode => 'Introduce el código de 8 caracteres';

  @override
  String joinedGroup(String name) {
    return '¡Te uniste a $name! 🎉';
  }

  @override
  String get invalidGroupCode =>
      'Código inválido. Comprueba e inténtalo de nuevo.';

  @override
  String get noGroupsYet => 'Sin grupos aún';

  @override
  String get noGroupsBody =>
      'Crea un grupo privado para tu equipo o empresa, o únete a uno con un código de invitación.';

  @override
  String get inviteCodeCopied => '¡Código de invitación copiado!';

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get createPrivateGroup => 'Crear un grupo privado';

  @override
  String get createGroupBody =>
      'Los partidos publicados en este grupo solo son visibles para los miembros. Comparte el código de invitación para hacer crecer tu grupo.';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get couldNotCreateGroup =>
      'No se pudo crear el grupo. Inténtalo de nuevo.';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get shareCodeToJoin =>
      'Comparte este código para que otros puedan unirse';

  @override
  String get codeCopiedToClipboard => '¡Código copiado al portapapeles!';

  @override
  String get members => 'Miembros';

  @override
  String get leaveGroup => 'Salir del grupo';

  @override
  String get leaveGroupBody =>
      'Ya no verás los partidos privados de este grupo.';

  @override
  String get searchPlayersHint => 'Buscar jugadores por nombre de usuario…';

  @override
  String get searchForPlayers => 'Buscar jugadores por nombre de usuario';

  @override
  String noPlayersFound(String query) {
    return 'No se encontraron jugadores para \"$query\"';
  }

  @override
  String get player => 'Jugador';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get markAllRead => 'Marcar todo como leído';

  @override
  String get noNotificationsYet => 'Sin notificaciones aún';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(int n) {
    return 'hace ${n}min';
  }

  @override
  String hoursAgo(int n) {
    return 'hace ${n}h';
  }

  @override
  String daysAgo(int n) {
    return 'hace ${n}d';
  }

  @override
  String get sportFootball => 'Fútbol';

  @override
  String get sportPadel => 'Pádel';

  @override
  String get sportRunning => 'Running';

  @override
  String get sportBasketball => 'Baloncesto';

  @override
  String get sportTennis => 'Tenis';

  @override
  String get sportCycling => 'Ciclismo';

  @override
  String get sportOther => 'Otro';

  @override
  String get skillAllLevels => 'Todos los niveles';

  @override
  String get skillBeginner => 'Principiante';

  @override
  String get skillIntermediate => 'Intermedio';

  @override
  String get skillExpert => 'Experto';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Español';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get almostThere => '¡Casi listo!';

  @override
  String get optionalInfoSubtitle => 'Opcional — puedes cambiarlo después';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get gender => 'Género';

  @override
  String get male => 'Hombre';

  @override
  String get female => 'Mujer';

  @override
  String get nonBinary => 'No binario';

  @override
  String get privacySection => 'Privacidad';

  @override
  String get showAgeOnProfile => 'Mostrar edad en el perfil';

  @override
  String get showGenderOnProfile => 'Mostrar género en el perfil';

  @override
  String get connectionLost => 'Sin conexión a internet';

  @override
  String get connectionRestored => 'Conexión restablecida';

  @override
  String get couldNotSaveAvailability => 'No se pudo guardar la disponibilidad';

  @override
  String get couldNotSaveProfile => 'No se pudo guardar el perfil';

  @override
  String get couldNotLeaveMatch => 'No se pudo salir del partido';

  @override
  String get couldNotConfirmMatch => 'No se pudo confirmar el partido';

  @override
  String get leaveMatchQuestion => '¿Salir del partido?';

  @override
  String get leaveMatchBody => 'Perderás tu lugar en este partido.';

  @override
  String get matchNotFound => 'Este partido ya no existe';

  @override
  String get locationRequired => 'El lugar es obligatorio';

  @override
  String get dateInPast => 'La fecha del partido debe ser en el futuro';

  @override
  String get usernameTaken => 'Este nombre de usuario ya está en uso';

  @override
  String get checkingUsername => 'Verificando…';

  @override
  String get usernameAvailable => 'Nombre de usuario disponible';

  @override
  String get next => 'Siguiente →';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get retry => 'Reintentar';

  @override
  String get noMatchesYet => 'Sin partidos aún';

  @override
  String get createOrJoin => '¡Crea un partido o únete a uno desde el inicio!';

  @override
  String get genderRestriction => 'Quién puede unirse';

  @override
  String get genderRestrictionHint => 'Dejar vacío para todos';

  @override
  String get openToAllGenders => 'Abierto a todos';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPasswordSent =>
      'Si existe una cuenta para ese correo, se ha enviado un enlace de restablecimiento.';

  @override
  String get send => 'Enviar';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountWarning =>
      'Esto eliminará permanentemente tu cuenta, partidos y todos los datos asociados. Esta acción no se puede deshacer.';

  @override
  String get typeDeleteToConfirm => 'Escribe DELETE para confirmar:';

  @override
  String get legalSection => 'Legal';

  @override
  String lastUpdated(String date) {
    return 'Última actualización: $date';
  }

  @override
  String get iAcceptThe => 'Acepto los ';

  @override
  String get termsOfService => 'términos de servicio';

  @override
  String get andThe => ' y la ';

  @override
  String get privacyPolicy => 'política de privacidad';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get chooseAppearance => 'Elegir apariencia';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordChanged => 'Contraseña cambiada';

  @override
  String get phoneSaved => 'Número de teléfono guardado';

  @override
  String get notSet => 'No definido';

  @override
  String get errorAlreadyJoined => 'Ya estás en este partido';

  @override
  String get errorMatchFull => 'Este partido está completo';

  @override
  String get errorCouldNotJoin => 'No se pudo unir al partido';

  @override
  String get errorCouldNotLeave => 'No se pudo salir del partido';

  @override
  String get errorCouldNotCreate => 'No se pudo crear el partido';

  @override
  String get errorCouldNotConfirm => 'No se pudo confirmar el partido';

  @override
  String get errorInvalidClaimCode => 'Código inválido o plaza ya ocupada';

  @override
  String get errorCouldNotAddGuests => 'No se pudieron añadir invitados';

  @override
  String get errorCouldNotLoadMatches => 'No se pudieron cargar los partidos';

  @override
  String get errorCouldNotLoadProfile => 'No se pudo cargar el perfil';

  @override
  String get errorCouldNotSaveProfile => 'No se pudo guardar el perfil';

  @override
  String get errorCouldNotUploadPhoto => 'No se pudo subir la foto';

  @override
  String get errorCouldNotCompleteSetup =>
      'No se pudo completar la configuración';

  @override
  String get errorCouldNotSaveLocation => 'No se pudo guardar la ubicación';

  @override
  String get errorCouldNotLoadGroups => 'No se pudieron cargar los grupos';

  @override
  String get errorCouldNotCreateGroup => 'No se pudo crear el grupo';

  @override
  String get errorCouldNotJoinGroup => 'No se pudo unir al grupo';

  @override
  String get errorCouldNotLeaveGroup => 'No se pudo salir del grupo';

  @override
  String get errorInvalidInviteCode => 'Código de invitación inválido';

  @override
  String get errorCouldNotDeleteAccount => 'No se pudo eliminar la cuenta';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get errorEmailTaken => 'Ya existe una cuenta con este correo';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get genderRestrictionMustIncludeSelf =>
      'No puedes excluir tu propio género de un partido que creas';

  @override
  String get genderRestrictionSetGenderFirst =>
      'Indica tu género en tu perfil para restringir un partido';

  @override
  String get supportSection => 'Soporte';

  @override
  String get reportBug => 'Informar de un error';

  @override
  String get reportBugSubtitle => '¿Algo no funciona? Cuéntanos';

  @override
  String get bugTypeBug => 'Error';

  @override
  String get bugTypeSuggestion => 'Sugerencia';

  @override
  String get bugTypeOther => 'Otro';

  @override
  String get bugDescriptionHint => 'Describe lo que pasó…';

  @override
  String get bugReportSent => '¡Gracias! Tu informe ha sido enviado.';

  @override
  String get bugReportTooShort =>
      'Danos un poco más de detalle (mín. 10 caracteres)';

  @override
  String guestNumber(int number) {
    return 'Invitado $number';
  }

  @override
  String get noPlayersYet => 'Aún no hay jugadores';

  @override
  String get unclaimedSpot => 'Plaza sin reclamar';

  @override
  String get addGuest => 'Añadir invitado';

  @override
  String get guestClaimCodeInfo =>
      'Se generará un código de invitación para cada plaza de invitado.';

  @override
  String get removeGuestQuestion => '¿Quitar invitado?';

  @override
  String get removeGuestBody => 'Esta plaza de invitado quedará libre.';

  @override
  String get matchCancelledBanner => 'Partido cancelado';

  @override
  String get cancelledBadge => 'CANCELADO';

  @override
  String get matchIsFull => 'Partido completo';

  @override
  String get selectTime => 'Elegir la hora';

  @override
  String get confirm => 'Confirmar';

  @override
  String shareInviteText(String deepLink, String code) {
    return '🎮 ¡Te han invitado a un partido de GameOn!\n\n¿Tienes la app? Reclama tu plaza:\n$deepLink\n\nCódigo manual: $code';
  }

  @override
  String get shareInviteSubject => 'Únete a mi partido de GameOn';

  @override
  String get inviteCopied => 'Invitación copiada al portapapeles';

  @override
  String get joinBringFriendsInfo =>
      'Trae amigos: se generará un código para cada plaza de invitado.';

  @override
  String addGuestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count invitados',
      one: 'Añadir 1 invitado',
    );
    return '$_temp0';
  }

  @override
  String get unlimitedSpots => 'Plazas ilimitadas';

  @override
  String get unlimitedSpotsHint => 'Cualquiera puede unirse — sin límite';

  @override
  String get unlimitedOpenToAll => 'Ilimitado — abierto a todos';

  @override
  String get loading => 'Cargando…';

  @override
  String get spotClaimed => '¡Plaza reclamada!';

  @override
  String get filters => 'Filtros';

  @override
  String get resetFilters => 'Restablecer';

  @override
  String get filterOff => 'Desactivado';

  @override
  String get showResults => 'Ver resultados';

  @override
  String get community => 'Comunidad';

  @override
  String get searchCommunityHint => 'Buscar jugadores o grupos…';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get member => 'Miembro';

  @override
  String get groupVisibility => 'Visibilidad';

  @override
  String get visibilityPublic => 'Público';

  @override
  String get visibilityPrivate => 'Privado';

  @override
  String get visibilityInviteOnly => 'Con solicitud';

  @override
  String get visibilityPublicDesc => 'Cualquiera puede encontrarlo y unirse';

  @override
  String get visibilityPrivateDesc =>
      'Oculto — solo se entra con el código de invitación';

  @override
  String get visibilityInviteOnlyDesc =>
      'Visible, pero unirse requiere aprobación';

  @override
  String get requestToJoin => 'Solicitar';

  @override
  String get requested => 'Solicitado';

  @override
  String get joinRequests => 'Solicitudes de unión';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get exampleGroupName => 'p. ej. Club deportivo Acme';

  @override
  String get groupAboutHint => '¿De qué trata este grupo?';

  @override
  String get exampleMatchTitle => 'p. ej. Fútbol 5 del domingo';

  @override
  String get exampleLocation => 'p. ej. Stade Marcel Michelin, pista 3';

  @override
  String get exampleUsername => 'p. ej. Zidane10';

  @override
  String get exampleBio => 'p. ej. Deportista de finde, fan del fútbol 5…';

  @override
  String get usernameRequired => 'Se requiere un nombre de usuario';

  @override
  String get usernameTooShort => 'Mínimo 3 caracteres';

  @override
  String get usernameTooLong => 'Máximo 20 caracteres';

  @override
  String get usernameCharset => 'Solo letras, números y _';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitados',
      one: '1 invitado',
    );
    return '$_temp0';
  }

  @override
  String get reportUser => 'Denunciar al jugador';

  @override
  String get reportMatch => 'Denunciar el partido';

  @override
  String get blockUser => 'Bloquear al jugador';

  @override
  String get unblockUser => 'Desbloquear al jugador';

  @override
  String get block => 'Bloquear';

  @override
  String get blockUserBody => 'Ya no verás sus partidos. No se le notificará.';

  @override
  String get userBlocked => 'Jugador bloqueado';

  @override
  String get userUnblocked => 'Jugador desbloqueado';

  @override
  String get reportSent => 'Denuncia enviada. Gracias por cuidar GameOn.';

  @override
  String get reportReason => 'Motivo';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get reasonHarassment => 'Acoso';

  @override
  String get reasonInappropriate => 'Contenido inapropiado';

  @override
  String get reasonFake => 'Perfil falso';

  @override
  String get reportDetailsHint => 'Añade detalles (opcional)';

  @override
  String get sponsored => 'Patrocinado';

  @override
  String get spotsAvailable => 'Plazas disponibles';

  @override
  String spotsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plazas libres',
      one: '1 plaza libre',
      zero: 'Completo',
    );
    return '$_temp0';
  }
}
