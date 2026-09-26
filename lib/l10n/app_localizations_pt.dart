// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Artex';

  @override
  String get welcomeToArtex => 'Bem-vindo ao Artex';

  @override
  String get chooseLanguage => 'Escolha o seu idioma';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get portuguese => 'Português';

  @override
  String get english => 'Inglês';

  @override
  String get spanish => 'Espanhol';

  @override
  String get home => 'Início';

  @override
  String get myArea => 'Minha área';

  @override
  String get explore => 'Explorar';

  @override
  String get logout => 'Sair';

  @override
  String get homeFeed => 'Feed inicial';

  @override
  String get currentlyWatching => 'A acompanhar';

  @override
  String get seeMore => 'Ver mais';

  @override
  String get likedPieces => 'Peças de que gostei';

  @override
  String get topLikedPieces => 'Peças mais apreciadas';

  @override
  String get favouriteArtists => 'Artistas favoritos';

  @override
  String get recommendedForYou => 'Recomendado para si';

  @override
  String piecesCount(int count) {
    return '$count peças';
  }

  @override
  String get searchByPieceAuthorType => 'Pesquisar por peça, autor ou tipo';

  @override
  String get all => 'Todos';

  @override
  String get audio => 'Áudio';

  @override
  String get text => 'Texto';

  @override
  String get picture => 'Imagem';

  @override
  String get audioDuration => 'Duração do áudio';

  @override
  String get readingTime => 'Tempo de leitura';

  @override
  String get anyDuration => 'Qualquer duração';

  @override
  String get underFiveMinutes => 'Menos de 5 min';

  @override
  String get fiveToFifteenMinutes => '5–15 min';

  @override
  String get overFifteenMinutes => 'Mais de 15 min';

  @override
  String get anyReadingTime => 'Qualquer tempo de leitura';

  @override
  String get noRecommendations =>
      'Nenhuma recomendação corresponde aos filtros.';

  @override
  String get createdPieces => 'Peças criadas';

  @override
  String get piecesInDevelopment => 'Peças em desenvolvimento';

  @override
  String get createNewArtPiece => 'Criar nova peça';

  @override
  String get definitions => 'Definições';

  @override
  String get accountDetails => 'Detalhes da conta';

  @override
  String get friends => 'Amigos';

  @override
  String get friendRequests => 'Pedidos de amizade';

  @override
  String get settingsSubtitle => 'Gerir email, palavra-passe, conta e sessão.';

  @override
  String get publishedPiecesSubtitle => 'Ver as suas peças publicadas.';

  @override
  String get draftsSubtitle => 'Continue a trabalhar nos seus rascunhos.';

  @override
  String get createPieceSubtitle =>
      'Comece uma peça de imagem, áudio ou texto.';

  @override
  String get accountDetailsSubtitle =>
      'Edite o perfil, imagem, descrição e idioma.';

  @override
  String get friendsSubtitle => 'Ver a sua lista de amigos.';

  @override
  String get friendRequestsSubtitle => 'Reveja quem quer ligar-se a si.';

  @override
  String get pleaseLogIn => 'Inicie sessão para ver a sua área.';

  @override
  String get pleaseLogInAgain => 'Inicie sessão novamente.';

  @override
  String get noFriends => 'Os seus amigos aparecerão aqui.';

  @override
  String get noFriendRequests => 'Não tem pedidos de amizade pendentes.';

  @override
  String get searchEmpty => 'Nenhum resultado encontrado';

  @override
  String get authorProfile => 'Perfil do autor';

  @override
  String get artistProfile => 'Perfil do artista';

  @override
  String get createdPiecesProfile => 'Peças criadas';

  @override
  String viewPublishedWork(Object name) {
    return 'Ver o trabalho publicado de $name';
  }

  @override
  String get likesAcrossPublishedPieces =>
      'Gostos recebidos nas peças publicadas';

  @override
  String get addFriend => 'Adicionar amigo';

  @override
  String get friendRequestSent => 'Pedido de amizade enviado.';

  @override
  String get friendRequestFailed =>
      'Não foi possível enviar o pedido de amizade.';

  @override
  String get accept => 'Aceitar';

  @override
  String get reject => 'Rejeitar';

  @override
  String get friendRequestAccepted => 'Pedido aceite.';

  @override
  String get friendRequestRejected => 'Pedido rejeitado.';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get removeFriend => 'Remover amigo';

  @override
  String get removeFriendConfirmation =>
      'Tem a certeza de que deseja remover este amigo?';

  @override
  String get friendRemoved => 'Amigo removido.';

  @override
  String get remove => 'Remover';

  @override
  String get chat => 'Conversar';

  @override
  String get writeMessage => 'Escreva uma mensagem';

  @override
  String get send => 'Enviar';

  @override
  String get viewPublishedPieces => 'Ver as suas peças publicadas.';

  @override
  String get continueDrafts => 'Continue a trabalhar nos seus rascunhos.';

  @override
  String get artPieceCreatedSuccessfully => 'Peça criada com sucesso.';

  @override
  String get noDraftsYet => 'Nenhum rascunho';

  @override
  String get noPublishedPiecesYet => 'Nenhuma peça criada ainda';

  @override
  String get loading => 'A carregar…';

  @override
  String get loadPiecesError =>
      'Não foi possível carregar as suas peças. Tente novamente.';

  @override
  String get noPiecesAvailable =>
      'Não existem peças disponíveis neste momento.';

  @override
  String get noComments => 'Ainda não existem comentários.';

  @override
  String get writeComment => 'Escreva um comentário';

  @override
  String get addComment => 'Adicionar comentário';

  @override
  String get commentsLoadFailed => 'Não foi possível carregar os comentários.';

  @override
  String get commentFailed => 'Não foi possível adicionar o comentário.';

  @override
  String totalLikes(int count) {
    return '$count gostos';
  }

  @override
  String get totalLikesLabel => 'Total de gostos';

  @override
  String get seeComments => 'Ver comentários';

  @override
  String translateTo(Object language) {
    return 'Traduzir para $language';
  }

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String get listenToAudio => 'Ouvir áudio';

  @override
  String get stopAudio => 'Parar áudio';

  @override
  String get playAudio => 'Reproduzir áudio';

  @override
  String get pauseAudio => 'Pausar áudio';

  @override
  String get readText => 'Ler texto';

  @override
  String get hideText => 'Ocultar texto';

  @override
  String formatNotSupported(Object format) {
    return 'O formato $format não é suportado nativamente';
  }

  @override
  String get invalidBase64 => 'Este conteúdo tem dados Base64 inválidos.';

  @override
  String get unsupportedAudio =>
      'Formato de áudio não suportado. Esperado MP3, FLAC ou M4A.';

  @override
  String get audioInitFailed => 'Não foi possível iniciar o áudio.';

  @override
  String get textToSpeechUnavailable =>
      'A conversão de texto para voz não está disponível.';

  @override
  String get loadingMedia => 'A carregar conteúdo…';

  @override
  String get createArtPiece => 'Criar peça';

  @override
  String get whatCreating => 'O que está a criar?';

  @override
  String get published => 'Publicado';

  @override
  String get publish => 'Publicar';

  @override
  String get publishDraftConfirmation =>
      'Tem a certeza de que deseja publicar este rascunho?';

  @override
  String get publishedSuccessfully => 'Rascunho publicado com sucesso.';

  @override
  String get inDevelopment => 'Em desenvolvimento';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descrição';

  @override
  String get textContent => 'Conteúdo de texto';

  @override
  String get saveArtPiece => 'Guardar peça';

  @override
  String get chooseFromGallery => 'Escolher da galeria';

  @override
  String get takePicture => 'Tirar fotografia';

  @override
  String get chooseAudioFile => 'Escolher ficheiro de áudio';

  @override
  String get recordAudio => 'Gravar áudio';

  @override
  String get stopRecording => 'Parar gravação';

  @override
  String get saveChanges => 'Guardar alterações';

  @override
  String get changeProfilePicture => 'Alterar fotografia de perfil';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get language => 'Idioma';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Câmara';

  @override
  String get email => 'Email';

  @override
  String get password => 'Palavra-passe';

  @override
  String get logIn => 'Iniciar sessão';

  @override
  String get signUp => 'Registar';

  @override
  String get needAccount => 'Precisa de uma conta? Registe-se';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? Inicie sessão';

  @override
  String get passwordMin => 'Use pelo menos 6 caracteres';

  @override
  String get emailRequired => 'Introduza o seu email';

  @override
  String get usernameRequired => 'O nome de utilizador é obrigatório';

  @override
  String get titleRequired => 'O título é obrigatório';

  @override
  String get microphonePermissionRequired =>
      'É necessária permissão do microfone para gravar áudio.';

  @override
  String get audioSizeGuidance =>
      'Mantenha as gravações abaixo de 2 minutos e 700 KB.';

  @override
  String get audioTooLarge =>
      'Este áudio excede 700 KB. Escolha um ficheiro menor ou mais curto.';

  @override
  String get mediaContentRequired =>
      'Adicione primeiro o conteúdo multimédia necessário.';

  @override
  String get textContentRequired => 'Adicione algum texto.';

  @override
  String get savePieceFailed => 'Não foi possível guardar esta peça';

  @override
  String get pictureReady => 'Imagem pronta (comprimida para Base64).';

  @override
  String get audioReady => 'Áudio pronto para pré-visualização.';

  @override
  String audioBytes(int count) {
    return '$count bytes';
  }

  @override
  String get insertImageBase64 => 'Inserir imagem opcional como Base64';

  @override
  String get interleavedImageNotice =>
      'A imagem opcional será intercalada com o texto como Base64.';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deletePiece => 'Eliminar peça?';

  @override
  String get areYouSure => 'Tem a certeza?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePieceFailed => 'Não foi possível eliminar esta peça.';

  @override
  String get cannotLikeOwnPiece => 'Não pode gostar da sua própria peça.';

  @override
  String get likeFailed => 'Não foi possível gostar desta peça.';

  @override
  String get profileSetup => 'Configurar o seu perfil';

  @override
  String get addProfilePictureOptional =>
      'Adicionar fotografia de perfil (opcional)';

  @override
  String get shortDescriptionOptional => 'Descrição curta (opcional)';

  @override
  String get finish => 'Concluir';

  @override
  String get imageLoadFailed => 'Não foi possível carregar essa imagem.';

  @override
  String get profileSaveFailed =>
      'Não foi possível guardar o seu perfil. Tente novamente.';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get forgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get invalidCredentials =>
      'O email ou a palavra-passe estão incorretos.';

  @override
  String get accountAlreadyExists => 'Já existe uma conta para este email.';

  @override
  String get invalidEmail => 'Introduza um email válido.';

  @override
  String get authenticationFailed => 'A autenticação falhou. Tente novamente.';

  @override
  String get resetEmailSent => 'Email de recuperação da palavra-passe enviado.';

  @override
  String get credits => 'Créditos';

  @override
  String get creditsMenuSubtitle => 'Sobre a aplicação e o seu criador.';

  @override
  String get creditsCreatedBy => 'Criado por';

  @override
  String get creditsRepository => 'Repositório GitHub';

  @override
  String get creditsOpenSource =>
      'O ArteX é um projeto de código aberto. Contribuições são bem-vindas!';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link.';

  @override
  String get suggestions => 'Sugestões';

  @override
  String get suggestionsMenuSubtitle => 'Envie ideias para melhorar o ArteX.';

  @override
  String get suggestionsTitle => 'Partilhe as suas ideias';

  @override
  String get suggestionsSubtitle =>
      'Tem alguma sugestão ou pedido de funcionalidade? Adoramos ouvir!';

  @override
  String get suggestionLabel => 'A sua sugestão';

  @override
  String get suggestionHint => 'Descreva a sua ideia ou melhoria...';

  @override
  String get suggestionRequired => 'Por favor escreva a sua sugestão primeiro.';

  @override
  String get suggestionSend => 'Enviar sugestão';

  @override
  String get suggestionSentSuccess => 'Sugestão enviada com sucesso. Obrigado!';

  @override
  String get suggestionSentFailed =>
      'Não foi possível enviar a sua sugestão. Tente novamente.';
}
