enum LegalPageType { terms, privacy }

class LegalSection {
  final String heading;
  final String body;
  const LegalSection({required this.heading, required this.body});
}

class LegalDocument {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;
  const LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });
}

const Map<String, Map<LegalPageType, LegalDocument>> legalContent = {
  // ═══════════════════════════════════════════════════════════════════════════
  // ENGLISH
  // ═══════════════════════════════════════════════════════════════════════════
  'en': {
    LegalPageType.terms: LegalDocument(
      title: 'Terms of Service',
      lastUpdated: '2025-06-01',
      sections: [
        LegalSection(
          heading: '1. Acceptance of Terms',
          body:
              'By creating an account or using GameOn ("the App"), you agree to be bound by these Terms of Service. If you do not agree, do not use the App. We may update these Terms from time to time; continued use after changes constitutes acceptance.',
        ),
        LegalSection(
          heading: '2. Eligibility',
          body:
              'You must be at least 13 years of age to use GameOn. If you are under 18, you represent that a parent or legal guardian has reviewed and agreed to these Terms on your behalf.',
        ),
        LegalSection(
          heading: '3. User Accounts',
          body:
              'You are responsible for maintaining the confidentiality of your login credentials and for all activity under your account. You agree to provide accurate information during registration. GameOn reserves the right to suspend or terminate accounts that violate these Terms.',
        ),
        LegalSection(
          heading: '4. Match Participation',
          body:
              'GameOn facilitates the organisation of sports matches between users. By joining or creating a match, you acknowledge that:\n'
              '• Participation is voluntary and at your own risk.\n'
              '• You are responsible for assessing your own fitness and health before engaging in any physical activity.\n'
              '• GameOn does not verify the identity, skill level, or physical condition of participants.\n'
              '• You should arrive at the agreed time and location and communicate promptly if plans change.',
        ),
        LegalSection(
          heading: '5. User Conduct',
          body:
              'You agree not to:\n'
              '• Use the App for any unlawful purpose.\n'
              '• Harass, threaten, or discriminate against other users.\n'
              '• Post false, misleading, or offensive content.\n'
              '• Attempt to gain unauthorised access to other accounts or systems.\n'
              '• Use automated tools to scrape data or abuse the service.\n\n'
              'GameOn reserves the right to remove content or suspend accounts that violate these rules.',
        ),
        LegalSection(
          heading: '6. Guest Invitations',
          body:
              'Match hosts may invite guests using unique claim codes. Hosts are responsible for guests they invite. GameOn is not liable for the behaviour of invited guests.',
        ),
        LegalSection(
          heading: '7. Groups',
          body:
              'Users may create or join private groups. Group creators are responsible for managing membership and content within their groups. GameOn does not monitor private group activity but may act upon reported violations.',
        ),
        LegalSection(
          heading: '8. Intellectual Property',
          body:
              'All content, trademarks, and logos within the App are the property of GameOn or its licensors. You retain ownership of content you post but grant GameOn a non-exclusive, royalty-free licence to display it within the App.',
        ),
        LegalSection(
          heading: '9. Limitation of Liability',
          body:
              'GameOn is provided "as is" without warranties of any kind. To the fullest extent permitted by law:\n'
              '• GameOn is not liable for any injuries, damages, or losses arising from match participation.\n'
              '• GameOn is not liable for interactions between users, whether online or in person.\n'
              '• GameOn does not guarantee the availability, accuracy, or reliability of the service.\n'
              '• In no event shall GameOn\'s total liability exceed the amount you paid to use the App in the 12 months preceding the claim.',
        ),
        LegalSection(
          heading: '10. Termination',
          body:
              'You may delete your account at any time from the Settings screen. GameOn may terminate or suspend your access for violation of these Terms or for any reason with reasonable notice. Upon termination, your data will be deleted in accordance with our Privacy Policy.',
        ),
        LegalSection(
          heading: '11. Governing Law',
          body:
              'These Terms are governed by and construed in accordance with the laws of France. Any disputes shall be submitted to the exclusive jurisdiction of the courts of Paris, France.',
        ),
        LegalSection(
          heading: '12. Contact',
          body:
              'For questions about these Terms, contact us at support@gameon-app.com.',
        ),
      ],
    ),
    LegalPageType.privacy: LegalDocument(
      title: 'Privacy Policy',
      lastUpdated: '2025-06-01',
      sections: [
        LegalSection(
          heading: '1. Introduction',
          body:
              'GameOn ("we", "us", "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, store, and share your personal data when you use the GameOn mobile application.',
        ),
        LegalSection(
          heading: '2. Data We Collect',
          body:
              'We collect the following categories of data:\n\n'
              'Account data: email address, username, and password (hashed).\n\n'
              'Profile data: bio, favourite sports, profile photo, date of birth, and gender (all optional).\n\n'
              'Match data: matches you create or join, locations, dates, times, and participant information.\n\n'
              'Usage data: app interactions, feature usage, and crash reports.\n\n'
              'Device data: device type, operating system, and app version.',
        ),
        LegalSection(
          heading: '3. How We Use Your Data',
          body:
              'We use your data to:\n'
              '• Provide and improve the GameOn service.\n'
              '• Display your profile to other users.\n'
              '• Facilitate match organisation and group management.\n'
              '• Send notifications about matches and activity.\n'
              '• Analyse usage trends to improve the App.\n'
              '• Comply with legal obligations.',
        ),
        LegalSection(
          heading: '4. Location Data',
          body:
              'Match locations are stored as coordinates to display matches on a map and enable nearby filtering. We do not continuously track your device location. Location data is only collected when you create a match or use the nearby filter.',
        ),
        LegalSection(
          heading: '5. Data Sharing',
          body:
              'We do not sell your personal data. We may share data with:\n'
              '• Other GameOn users: your public profile (username, bio, favourite sports, avatar) and match participation are visible to other users.\n'
              '• Service providers: we use Supabase for authentication and database services. Your data is processed in accordance with their privacy policies.\n'
              '• Legal authorities: if required by law or to protect our rights.',
        ),
        LegalSection(
          heading: '6. Data Retention',
          body:
              'We retain your data for as long as your account is active. When you delete your account, we delete your personal data within 30 days, except where retention is required by law. Anonymous, aggregated data may be retained for analytics.',
        ),
        LegalSection(
          heading: '7. Your Rights (GDPR)',
          body:
              'If you are located in the European Economic Area, you have the right to:\n'
              '• Access your personal data.\n'
              '• Rectify inaccurate data.\n'
              '• Erase your data ("right to be forgotten").\n'
              '• Restrict or object to processing.\n'
              '• Data portability.\n'
              '• Withdraw consent at any time.\n\n'
              'To exercise these rights, contact us at privacy@gameon-app.com.',
        ),
        LegalSection(
          heading: '8. Privacy Controls',
          body:
              'You can control your privacy within the App:\n'
              '• Choose whether to display your age and gender on your profile.\n'
              '• Edit or remove your bio and profile photo at any time.\n'
              '• Delete your account entirely from the Settings screen.',
        ),
        LegalSection(
          heading: '9. Children\'s Privacy',
          body:
              'GameOn is not intended for children under 13. We do not knowingly collect data from children under 13. If we learn that we have collected data from a child under 13, we will delete it promptly.',
        ),
        LegalSection(
          heading: '10. Security',
          body:
              'We implement industry-standard security measures to protect your data, including encrypted connections (TLS), hashed passwords, and row-level security policies. However, no system is completely secure, and we cannot guarantee absolute security.',
        ),
        LegalSection(
          heading: '11. Changes to This Policy',
          body:
              'We may update this Privacy Policy from time to time. We will notify you of significant changes via the App or by email. Continued use after changes constitutes acceptance.',
        ),
        LegalSection(
          heading: '12. Contact',
          body:
              'For questions or requests regarding your personal data, contact us at privacy@gameon-app.com.',
        ),
      ],
    ),
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // FRENCH
  // ═══════════════════════════════════════════════════════════════════════════
  'fr': {
    LegalPageType.terms: LegalDocument(
      title: 'Conditions d\'utilisation',
      lastUpdated: '2025-06-01',
      sections: [
        LegalSection(
          heading: '1. Acceptation des conditions',
          body:
              'En créant un compte ou en utilisant GameOn (« l\'Application »), vous acceptez d\'être lié par les présentes Conditions d\'utilisation. Si vous n\'acceptez pas, n\'utilisez pas l\'Application. Nous pouvons mettre à jour ces Conditions de temps à autre ; la poursuite de l\'utilisation après les modifications vaut acceptation.',
        ),
        LegalSection(
          heading: '2. Éligibilité',
          body:
              'Vous devez avoir au moins 13 ans pour utiliser GameOn. Si vous avez moins de 18 ans, vous déclarez qu\'un parent ou tuteur légal a examiné et accepté ces Conditions en votre nom.',
        ),
        LegalSection(
          heading: '3. Comptes utilisateur',
          body:
              'Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toute activité sur votre compte. Vous acceptez de fournir des informations exactes lors de l\'inscription. GameOn se réserve le droit de suspendre ou supprimer les comptes en violation de ces Conditions.',
        ),
        LegalSection(
          heading: '4. Participation aux matchs',
          body:
              'GameOn facilite l\'organisation de rencontres sportives entre utilisateurs. En rejoignant ou en créant un match, vous reconnaissez que :\n'
              '• La participation est volontaire et à vos propres risques.\n'
              '• Vous êtes responsable d\'évaluer votre condition physique et votre santé avant toute activité sportive.\n'
              '• GameOn ne vérifie pas l\'identité, le niveau de compétence ni l\'état de santé des participants.\n'
              '• Vous devez vous présenter à l\'heure et au lieu convenus et communiquer rapidement en cas de changement.',
        ),
        LegalSection(
          heading: '5. Conduite des utilisateurs',
          body:
              'Vous vous engagez à ne pas :\n'
              '• Utiliser l\'Application à des fins illicites.\n'
              '• Harceler, menacer ou discriminer d\'autres utilisateurs.\n'
              '• Publier du contenu faux, trompeur ou offensant.\n'
              '• Tenter d\'accéder de manière non autorisée à d\'autres comptes ou systèmes.\n'
              '• Utiliser des outils automatisés pour extraire des données ou abuser du service.\n\n'
              'GameOn se réserve le droit de supprimer du contenu ou de suspendre des comptes en cas de violation de ces règles.',
        ),
        LegalSection(
          heading: '6. Invitations d\'invités',
          body:
              'Les organisateurs de matchs peuvent inviter des personnes à l\'aide de codes uniques. Les organisateurs sont responsables des invités qu\'ils convient. GameOn n\'est pas responsable du comportement des invités.',
        ),
        LegalSection(
          heading: '7. Groupes',
          body:
              'Les utilisateurs peuvent créer ou rejoindre des groupes privés. Les créateurs de groupes sont responsables de la gestion des membres et du contenu au sein de leurs groupes. GameOn ne surveille pas l\'activité des groupes privés, mais peut agir en cas de signalement de violations.',
        ),
        LegalSection(
          heading: '8. Propriété intellectuelle',
          body:
              'Tous les contenus, marques et logos de l\'Application sont la propriété de GameOn ou de ses concédants. Vous conservez la propriété du contenu que vous publiez, mais accordez à GameOn une licence non exclusive et gratuite pour l\'afficher dans l\'Application.',
        ),
        LegalSection(
          heading: '9. Limitation de responsabilité',
          body:
              'GameOn est fourni « en l\'état » sans garantie d\'aucune sorte. Dans toute la mesure permise par la loi :\n'
              '• GameOn n\'est pas responsable des blessures, dommages ou pertes résultant de la participation aux matchs.\n'
              '• GameOn n\'est pas responsable des interactions entre utilisateurs, en ligne ou en personne.\n'
              '• GameOn ne garantit pas la disponibilité, l\'exactitude ou la fiabilité du service.\n'
              '• En aucun cas, la responsabilité totale de GameOn ne pourra excéder le montant que vous avez payé pour utiliser l\'Application au cours des 12 mois précédant la réclamation.',
        ),
        LegalSection(
          heading: '10. Résiliation',
          body:
              'Vous pouvez supprimer votre compte à tout moment depuis l\'écran Paramètres. GameOn peut résilier ou suspendre votre accès en cas de violation de ces Conditions ou pour toute raison avec un préavis raisonnable. À la résiliation, vos données seront supprimées conformément à notre Politique de confidentialité.',
        ),
        LegalSection(
          heading: '11. Droit applicable',
          body:
              'Les présentes Conditions sont régies et interprétées conformément au droit français. Tout litige sera soumis à la compétence exclusive des tribunaux de Paris, France.',
        ),
        LegalSection(
          heading: '12. Contact',
          body:
              'Pour toute question concernant ces Conditions, contactez-nous à support@gameon-app.com.',
        ),
      ],
    ),
    LegalPageType.privacy: LegalDocument(
      title: 'Politique de confidentialité',
      lastUpdated: '2025-06-01',
      sections: [
        LegalSection(
          heading: '1. Introduction',
          body:
              'GameOn (« nous », « notre ») s\'engage à protéger votre vie privée. Cette Politique de confidentialité explique comment nous collectons, utilisons, stockons et partageons vos données personnelles lorsque vous utilisez l\'application mobile GameOn.',
        ),
        LegalSection(
          heading: '2. Données collectées',
          body:
              'Nous collectons les catégories de données suivantes :\n\n'
              'Données de compte : adresse e-mail, nom d\'utilisateur et mot de passe (haché).\n\n'
              'Données de profil : bio, sports favoris, photo de profil, date de naissance et genre (tous optionnels).\n\n'
              'Données de matchs : matchs que vous créez ou rejoignez, lieux, dates, horaires et informations sur les participants.\n\n'
              'Données d\'utilisation : interactions avec l\'application, utilisation des fonctionnalités et rapports de crash.\n\n'
              'Données d\'appareil : type d\'appareil, système d\'exploitation et version de l\'application.',
        ),
        LegalSection(
          heading: '3. Utilisation de vos données',
          body:
              'Nous utilisons vos données pour :\n'
              '• Fournir et améliorer le service GameOn.\n'
              '• Afficher votre profil aux autres utilisateurs.\n'
              '• Faciliter l\'organisation des matchs et la gestion des groupes.\n'
              '• Envoyer des notifications concernant les matchs et l\'activité.\n'
              '• Analyser les tendances d\'utilisation pour améliorer l\'Application.\n'
              '• Respecter les obligations légales.',
        ),
        LegalSection(
          heading: '4. Données de localisation',
          body:
              'Les lieux des matchs sont stockés sous forme de coordonnées pour afficher les matchs sur une carte et permettre le filtrage par proximité. Nous ne suivons pas en continu la position de votre appareil. Les données de localisation ne sont collectées que lorsque vous créez un match ou utilisez le filtre de proximité.',
        ),
        LegalSection(
          heading: '5. Partage des données',
          body:
              'Nous ne vendons pas vos données personnelles. Nous pouvons partager vos données avec :\n'
              '• D\'autres utilisateurs GameOn : votre profil public (pseudo, bio, sports favoris, avatar) et votre participation aux matchs sont visibles par les autres utilisateurs.\n'
              '• Prestataires de services : nous utilisons Supabase pour l\'authentification et les services de base de données. Vos données sont traitées conformément à leurs politiques de confidentialité.\n'
              '• Autorités légales : si la loi l\'exige ou pour protéger nos droits.',
        ),
        LegalSection(
          heading: '6. Conservation des données',
          body:
              'Nous conservons vos données tant que votre compte est actif. Lorsque vous supprimez votre compte, nous effaçons vos données personnelles dans un délai de 30 jours, sauf si la conservation est requise par la loi. Les données anonymes et agrégées peuvent être conservées à des fins analytiques.',
        ),
        LegalSection(
          heading: '7. Vos droits (RGPD)',
          body:
              'Si vous résidez dans l\'Espace économique européen, vous disposez des droits suivants :\n'
              '• Accéder à vos données personnelles.\n'
              '• Rectifier les données inexactes.\n'
              '• Effacer vos données (« droit à l\'oubli »).\n'
              '• Limiter ou vous opposer au traitement.\n'
              '• Portabilité des données.\n'
              '• Retirer votre consentement à tout moment.\n\n'
              'Pour exercer ces droits, contactez-nous à privacy@gameon-app.com.',
        ),
        LegalSection(
          heading: '8. Contrôles de confidentialité',
          body:
              'Vous pouvez contrôler votre confidentialité dans l\'Application :\n'
              '• Choisir d\'afficher ou non votre âge et votre genre sur votre profil.\n'
              '• Modifier ou supprimer votre bio et votre photo de profil à tout moment.\n'
              '• Supprimer entièrement votre compte depuis l\'écran Paramètres.',
        ),
        LegalSection(
          heading: '9. Protection des mineurs',
          body:
              'GameOn n\'est pas destiné aux enfants de moins de 13 ans. Nous ne collectons pas sciemment de données auprès d\'enfants de moins de 13 ans. Si nous apprenons avoir collecté des données d\'un enfant de moins de 13 ans, nous les supprimerons rapidement.',
        ),
        LegalSection(
          heading: '10. Sécurité',
          body:
              'Nous mettons en œuvre des mesures de sécurité conformes aux standards de l\'industrie pour protéger vos données, notamment des connexions chiffrées (TLS), des mots de passe hachés et des politiques de sécurité au niveau des lignes. Cependant, aucun système n\'est totalement sécurisé et nous ne pouvons garantir une sécurité absolue.',
        ),
        LegalSection(
          heading: '11. Modifications de cette politique',
          body:
              'Nous pouvons mettre à jour cette Politique de confidentialité de temps à autre. Nous vous informerons des changements significatifs via l\'Application ou par e-mail. La poursuite de l\'utilisation après les modifications vaut acceptation.',
        ),
        LegalSection(
          heading: '12. Contact',
          body:
              'Pour toute question ou demande relative à vos données personnelles, contactez-nous à privacy@gameon-app.com.',
        ),
      ],
    ),
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SPANISH
  // ═══════════════════════════════════════════════════════════════════════════
  'es': {
    LegalPageType.terms: LegalDocument(
      title: 'Términos de servicio',
      lastUpdated: '2025-06-01',
      sections: [
        LegalSection(
          heading: '1. Aceptación de los términos',
          body:
              'Al crear una cuenta o utilizar GameOn ("la Aplicación"), aceptas quedar vinculado por estos Términos de servicio. Si no estás de acuerdo, no utilices la Aplicación. Podemos actualizar estos Términos de vez en cuando; el uso continuado tras los cambios constituye aceptación.',
        ),
        LegalSection(
          heading: '2. Elegibilidad',
          body:
              'Debes tener al menos 13 años para usar GameOn. Si eres menor de 18 años, declaras que un padre o tutor legal ha revisado y aceptado estos Términos en tu nombre.',
        ),
        LegalSection(
          heading: '3. Cuentas de usuario',
          body:
              'Eres responsable de mantener la confidencialidad de tus credenciales de acceso y de toda la actividad en tu cuenta. Aceptas proporcionar información precisa durante el registro. GameOn se reserva el derecho de suspender o eliminar cuentas que infrinjan estos Términos.',
        ),
        LegalSection(
          heading: '4. Participación en partidos',
          body:
              'GameOn facilita la organización de encuentros deportivos entre usuarios. Al unirte o crear un partido, reconoces que:\n'
              '• La participación es voluntaria y bajo tu propio riesgo.\n'
              '• Eres responsable de evaluar tu propia condición física y salud antes de cualquier actividad deportiva.\n'
              '• GameOn no verifica la identidad, nivel de habilidad ni condición física de los participantes.\n'
              '• Debes presentarte en el horario y lugar acordados y comunicar con prontitud si hay cambios.',
        ),
        LegalSection(
          heading: '5. Conducta del usuario',
          body:
              'Te comprometes a no:\n'
              '• Usar la Aplicación para fines ilegales.\n'
              '• Acosar, amenazar o discriminar a otros usuarios.\n'
              '• Publicar contenido falso, engañoso u ofensivo.\n'
              '• Intentar acceder sin autorización a otras cuentas o sistemas.\n'
              '• Usar herramientas automatizadas para extraer datos o abusar del servicio.\n\n'
              'GameOn se reserva el derecho de eliminar contenido o suspender cuentas que infrinjan estas reglas.',
        ),
        LegalSection(
          heading: '6. Invitaciones de invitados',
          body:
              'Los organizadores de partidos pueden invitar a personas mediante códigos únicos. Los organizadores son responsables de los invitados que convidan. GameOn no es responsable del comportamiento de los invitados.',
        ),
        LegalSection(
          heading: '7. Grupos',
          body:
              'Los usuarios pueden crear o unirse a grupos privados. Los creadores de grupos son responsables de gestionar la membresía y el contenido dentro de sus grupos. GameOn no monitoriza la actividad de los grupos privados, pero puede actuar ante denuncias de infracciones.',
        ),
        LegalSection(
          heading: '8. Propiedad intelectual',
          body:
              'Todo el contenido, marcas y logotipos de la Aplicación son propiedad de GameOn o de sus licenciantes. Conservas la propiedad del contenido que publicas, pero otorgas a GameOn una licencia no exclusiva y gratuita para mostrarlo dentro de la Aplicación.',
        ),
        LegalSection(
          heading: '9. Limitación de responsabilidad',
          body:
              'GameOn se proporciona "tal cual" sin garantías de ningún tipo. En la máxima medida permitida por la ley:\n'
              '• GameOn no es responsable de lesiones, daños o pérdidas derivadas de la participación en partidos.\n'
              '• GameOn no es responsable de las interacciones entre usuarios, ya sean en línea o en persona.\n'
              '• GameOn no garantiza la disponibilidad, exactitud o fiabilidad del servicio.\n'
              '• En ningún caso la responsabilidad total de GameOn excederá la cantidad que hayas pagado por usar la Aplicación en los 12 meses anteriores a la reclamación.',
        ),
        LegalSection(
          heading: '10. Terminación',
          body:
              'Puedes eliminar tu cuenta en cualquier momento desde la pantalla de Ajustes. GameOn puede rescindir o suspender tu acceso por infracción de estos Términos o por cualquier motivo con aviso razonable. Tras la terminación, tus datos serán eliminados conforme a nuestra Política de privacidad.',
        ),
        LegalSection(
          heading: '11. Ley aplicable',
          body:
              'Estos Términos se rigen e interpretan de acuerdo con las leyes de Francia. Cualquier disputa se someterá a la jurisdicción exclusiva de los tribunales de París, Francia.',
        ),
        LegalSection(
          heading: '12. Contacto',
          body:
              'Para preguntas sobre estos Términos, contáctanos en support@gameon-app.com.',
        ),
      ],
    ),
    LegalPageType.privacy: LegalDocument(
      title: 'Política de privacidad',
      lastUpdated: '2025-06-01',
      sections: [
        LegalSection(
          heading: '1. Introducción',
          body:
              'GameOn ("nosotros", "nuestro") se compromete a proteger tu privacidad. Esta Política de privacidad explica cómo recopilamos, usamos, almacenamos y compartimos tus datos personales cuando utilizas la aplicación móvil GameOn.',
        ),
        LegalSection(
          heading: '2. Datos que recopilamos',
          body:
              'Recopilamos las siguientes categorías de datos:\n\n'
              'Datos de cuenta: dirección de correo electrónico, nombre de usuario y contraseña (cifrada).\n\n'
              'Datos de perfil: bio, deportes favoritos, foto de perfil, fecha de nacimiento y género (todos opcionales).\n\n'
              'Datos de partidos: partidos que creas o a los que te unes, ubicaciones, fechas, horarios e información de participantes.\n\n'
              'Datos de uso: interacciones con la aplicación, uso de funciones e informes de fallos.\n\n'
              'Datos del dispositivo: tipo de dispositivo, sistema operativo y versión de la aplicación.',
        ),
        LegalSection(
          heading: '3. Cómo usamos tus datos',
          body:
              'Usamos tus datos para:\n'
              '• Proporcionar y mejorar el servicio GameOn.\n'
              '• Mostrar tu perfil a otros usuarios.\n'
              '• Facilitar la organización de partidos y la gestión de grupos.\n'
              '• Enviar notificaciones sobre partidos y actividad.\n'
              '• Analizar tendencias de uso para mejorar la Aplicación.\n'
              '• Cumplir con obligaciones legales.',
        ),
        LegalSection(
          heading: '4. Datos de ubicación',
          body:
              'Las ubicaciones de los partidos se almacenan como coordenadas para mostrar los partidos en un mapa y permitir el filtrado por proximidad. No rastreamos continuamente la ubicación de tu dispositivo. Los datos de ubicación solo se recopilan cuando creas un partido o usas el filtro de proximidad.',
        ),
        LegalSection(
          heading: '5. Compartición de datos',
          body:
              'No vendemos tus datos personales. Podemos compartir datos con:\n'
              '• Otros usuarios de GameOn: tu perfil público (nombre de usuario, bio, deportes favoritos, avatar) y tu participación en partidos son visibles para otros usuarios.\n'
              '• Proveedores de servicios: utilizamos Supabase para autenticación y servicios de base de datos. Tus datos se procesan conforme a sus políticas de privacidad.\n'
              '• Autoridades legales: si lo exige la ley o para proteger nuestros derechos.',
        ),
        LegalSection(
          heading: '6. Conservación de datos',
          body:
              'Conservamos tus datos mientras tu cuenta esté activa. Cuando eliminas tu cuenta, borramos tus datos personales en un plazo de 30 días, excepto cuando la retención sea requerida por ley. Los datos anónimos y agregados pueden conservarse con fines analíticos.',
        ),
        LegalSection(
          heading: '7. Tus derechos (RGPD)',
          body:
              'Si resides en el Espacio Económico Europeo, tienes derecho a:\n'
              '• Acceder a tus datos personales.\n'
              '• Rectificar datos inexactos.\n'
              '• Suprimir tus datos ("derecho al olvido").\n'
              '• Limitar u oponerte al tratamiento.\n'
              '• Portabilidad de datos.\n'
              '• Retirar tu consentimiento en cualquier momento.\n\n'
              'Para ejercer estos derechos, contáctanos en privacy@gameon-app.com.',
        ),
        LegalSection(
          heading: '8. Controles de privacidad',
          body:
              'Puedes controlar tu privacidad dentro de la Aplicación:\n'
              '• Elegir si mostrar tu edad y género en tu perfil.\n'
              '• Editar o eliminar tu bio y foto de perfil en cualquier momento.\n'
              '• Eliminar tu cuenta por completo desde la pantalla de Ajustes.',
        ),
        LegalSection(
          heading: '9. Privacidad de menores',
          body:
              'GameOn no está dirigido a menores de 13 años. No recopilamos conscientemente datos de menores de 13 años. Si descubrimos que hemos recopilado datos de un menor de 13 años, los eliminaremos con prontitud.',
        ),
        LegalSection(
          heading: '10. Seguridad',
          body:
              'Implementamos medidas de seguridad conforme a los estándares de la industria para proteger tus datos, incluyendo conexiones cifradas (TLS), contraseñas cifradas y políticas de seguridad a nivel de fila. Sin embargo, ningún sistema es completamente seguro y no podemos garantizar una seguridad absoluta.',
        ),
        LegalSection(
          heading: '11. Cambios en esta política',
          body:
              'Podemos actualizar esta Política de privacidad de vez en cuando. Te notificaremos los cambios significativos a través de la Aplicación o por correo electrónico. El uso continuado tras los cambios constituye aceptación.',
        ),
        LegalSection(
          heading: '12. Contacto',
          body:
              'Para preguntas o solicitudes relativas a tus datos personales, contáctanos en privacy@gameon-app.com.',
        ),
      ],
    ),
  },
};
