// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Artex';

  @override
  String get welcomeToArtex => 'Bienvenido a Artex';

  @override
  String get chooseLanguage => 'Elige tu idioma';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get portuguese => 'Portugués';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get home => 'Inicio';

  @override
  String get myArea => 'Mi área';

  @override
  String get explore => 'Explorar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get homeFeed => 'Feed de inicio';

  @override
  String get currentlyWatching => 'Viendo ahora';

  @override
  String get seeMore => 'Ver más';

  @override
  String get likedPieces => 'Piezas favoritas';

  @override
  String get topLikedPieces => 'Piezas más gustadas';

  @override
  String get favouriteArtists => 'Artistas favoritos';

  @override
  String get recommendedForYou => 'Recomendado para ti';

  @override
  String piecesCount(int count) {
    return '$count piezas';
  }

  @override
  String get searchByPieceAuthorType => 'Buscar por pieza, autor o tipo';

  @override
  String get all => 'Todo';

  @override
  String get audio => 'Audio';

  @override
  String get text => 'Texto';

  @override
  String get picture => 'Imagen';

  @override
  String get audioDuration => 'Duración del audio';

  @override
  String get readingTime => 'Tiempo de lectura';

  @override
  String get anyDuration => 'Cualquier duración';

  @override
  String get underFiveMinutes => 'Menos de 5 min';

  @override
  String get fiveToFifteenMinutes => '5–15 min';

  @override
  String get overFifteenMinutes => 'Más de 15 min';

  @override
  String get anyReadingTime => 'Cualquier tiempo de lectura';

  @override
  String get noRecommendations =>
      'Ninguna recomendación coincide con los filtros.';

  @override
  String get createdPieces => 'Piezas creadas';

  @override
  String get piecesInDevelopment => 'Piezas en desarrollo';

  @override
  String get createNewArtPiece => 'Crear nueva pieza';

  @override
  String get definitions => 'Configuración';

  @override
  String get accountDetails => 'Detalles de la cuenta';

  @override
  String get friends => 'Amigos';

  @override
  String get friendRequests => 'Solicitudes de amistad';

  @override
  String get settingsSubtitle => 'Gestiona email, contraseña, cuenta y sesión.';

  @override
  String get publishedPiecesSubtitle => 'Ve tus piezas publicadas.';

  @override
  String get draftsSubtitle => 'Continúa trabajando en tus borradores.';

  @override
  String get createPieceSubtitle =>
      'Empieza una pieza de imagen, audio o texto.';

  @override
  String get accountDetailsSubtitle =>
      'Edita tu perfil, imagen, descripción e idioma.';

  @override
  String get friendsSubtitle => 'Ver tu lista de amigos.';

  @override
  String get friendRequestsSubtitle => 'Revisa quién quiere conectar contigo.';

  @override
  String get pleaseLogIn => 'Inicia sesión para ver tu área.';

  @override
  String get pleaseLogInAgain => 'Inicia sesión de nuevo.';

  @override
  String get noFriends => 'Tus amigos aparecerán aquí.';

  @override
  String get noFriendRequests => 'No tienes solicitudes pendientes.';

  @override
  String get searchEmpty => 'No se encontraron resultados';

  @override
  String get authorProfile => 'Perfil del autor';

  @override
  String get artistProfile => 'Perfil del artista';

  @override
  String get createdPiecesProfile => 'Piezas creadas';

  @override
  String viewPublishedWork(Object name) {
    return 'Ver el trabajo publicado de $name';
  }

  @override
  String get likesAcrossPublishedPieces =>
      'Me gusta obtenidos en piezas publicadas';

  @override
  String get addFriend => 'Añadir amigo';

  @override
  String get friendRequestSent => 'Solicitud de amistad enviada.';

  @override
  String get friendRequestFailed =>
      'No se pudo enviar la solicitud de amistad.';

  @override
  String get accept => 'Aceptar';

  @override
  String get reject => 'Rechazar';

  @override
  String get friendRequestAccepted => 'Solicitud de amistad aceptada.';

  @override
  String get friendRequestRejected => 'Solicitud de amistad rechazada.';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get removeFriend => 'Eliminar amigo';

  @override
  String get removeFriendConfirmation =>
      '¿Está seguro de que desea eliminar a este amigo?';

  @override
  String get friendRemoved => 'Amigo eliminado.';

  @override
  String get remove => 'Eliminar';

  @override
  String get chat => 'Mensaje';

  @override
  String get writeMessage => 'Escribe un mensaje';

  @override
  String get send => 'Enviar';

  @override
  String get viewPublishedPieces => 'Ver tus piezas de arte publicadas.';

  @override
  String get continueDrafts => 'Continúa trabajando en tus borradores.';

  @override
  String get artPieceCreatedSuccessfully => 'Pieza creada correctamente.';

  @override
  String get noDraftsYet => 'Aún no tienes borradores.';

  @override
  String get noPublishedPiecesYet => 'Aún no has publicado ninguna pieza.';

  @override
  String get loading => 'Cargando…';

  @override
  String get loadPiecesError =>
      'No se pudieron cargar tus piezas. Inténtalo de nuevo.';

  @override
  String get noPiecesAvailable => 'No hay piezas disponibles ahora.';

  @override
  String get noComments => 'Aún no hay comentarios.';

  @override
  String get writeComment => 'Escribe un comentario';

  @override
  String get addComment => 'Añadir comentario';

  @override
  String get commentsLoadFailed => 'No se pudieron cargar los comentarios.';

  @override
  String get commentFailed => 'No se pudo añadir el comentario.';

  @override
  String totalLikes(int count) {
    return '$count me gusta';
  }

  @override
  String get totalLikesLabel => 'Me gusta totales';

  @override
  String get seeComments => 'Ver comentarios';

  @override
  String translateTo(Object language) {
    return 'Traducir al $language';
  }

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String get listenToAudio => 'Escuchar audio';

  @override
  String get stopAudio => 'Detener audio';

  @override
  String get playAudio => 'Reproducir audio';

  @override
  String get pauseAudio => 'Pausar audio';

  @override
  String get readText => 'Leer texto';

  @override
  String get hideText => 'Ocultar texto';

  @override
  String formatNotSupported(Object format) {
    return 'El formato $format no es compatible de forma nativa';
  }

  @override
  String get invalidBase64 => 'Este contenido tiene datos Base64 no válidos.';

  @override
  String get unsupportedAudio =>
      'Formato de audio no compatible. Se esperaba MP3, FLAC o M4A.';

  @override
  String get audioInitFailed => 'No se pudo iniciar el audio.';

  @override
  String get textToSpeechUnavailable =>
      'La conversión de texto a voz no está disponible.';

  @override
  String get loadingMedia => 'Cargando contenido…';

  @override
  String get createArtPiece => 'Crear pieza';

  @override
  String get whatCreating => '¿Qué estás creando?';

  @override
  String get published => 'Publicado';

  @override
  String get publish => 'Publicar';

  @override
  String get publishDraftConfirmation =>
      '¿Está seguro de que desea publicar este borrador?';

  @override
  String get publishedSuccessfully => 'Borrador publicado correctamente.';

  @override
  String get inDevelopment => 'En desarrollo';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descripción';

  @override
  String get textContent => 'Contenido de texto';

  @override
  String get saveArtPiece => 'Guardar pieza';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get takePicture => 'Tomar una foto';

  @override
  String get chooseAudioFile => 'Elegir archivo de audio';

  @override
  String get recordAudio => 'Grabar audio';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get changeProfilePicture => 'Cambiar foto de perfil';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get language => 'Idioma';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get needAccount => '¿Necesitas una cuenta? Regístrate';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get passwordMin => 'Usa al menos 6 caracteres';

  @override
  String get emailRequired => 'Introduce tu email';

  @override
  String get usernameRequired => 'El nombre de usuario es obligatorio';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get microphonePermissionRequired =>
      'Se necesita permiso del micrófono para grabar audio.';

  @override
  String get audioSizeGuidance =>
      'Mantén las grabaciones por debajo de 2 minutos y 700 KB.';

  @override
  String get audioTooLarge =>
      'Este audio supera los 700 KB. Elige un archivo más corto o pequeño.';

  @override
  String get mediaContentRequired =>
      'Añade primero el contenido multimedia necesario.';

  @override
  String get textContentRequired => 'Añade algo de texto.';

  @override
  String get savePieceFailed => 'No se pudo guardar esta pieza';

  @override
  String get pictureReady => 'Imagen lista (comprimida a Base64).';

  @override
  String get audioReady => 'Audio listo para previsualizar.';

  @override
  String audioBytes(int count) {
    return '$count bytes';
  }

  @override
  String get insertImageBase64 => 'Insertar imagen opcional como Base64';

  @override
  String get interleavedImageNotice =>
      'La imagen opcional se intercalará con el texto como Base64.';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deletePiece => '¿Eliminar pieza?';

  @override
  String get areYouSure => '¿Estás seguro?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePieceFailed => 'No se pudo eliminar esta pieza.';

  @override
  String get cannotLikeOwnPiece =>
      'No puedes indicar que te gusta tu propia pieza.';

  @override
  String get likeFailed => 'No se pudo indicar que te gusta esta pieza.';

  @override
  String get profileSetup => 'Configura tu perfil';

  @override
  String get addProfilePictureOptional => 'Añadir foto de perfil (opcional)';

  @override
  String get shortDescriptionOptional => 'Descripción breve (opcional)';

  @override
  String get finish => 'Finalizar';

  @override
  String get imageLoadFailed => 'No se pudo cargar esa imagen.';

  @override
  String get profileSaveFailed =>
      'No se pudo guardar tu perfil. Inténtalo de nuevo.';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get invalidCredentials => 'El email o la contraseña son incorrectos.';

  @override
  String get accountAlreadyExists => 'Ya existe una cuenta para este email.';

  @override
  String get invalidEmail => 'Introduce un email válido.';

  @override
  String get authenticationFailed =>
      'La autenticación falló. Inténtalo de nuevo.';

  @override
  String get resetEmailSent => 'Email de recuperación de contraseña enviado.';
}
