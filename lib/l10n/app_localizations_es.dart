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
}
