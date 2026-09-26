// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Artex';

  @override
  String get welcomeToArtex => 'Welcome to Artex';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get continueLabel => 'Continue';

  @override
  String get portuguese => 'Português';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get home => 'Home';

  @override
  String get myArea => 'My Area';

  @override
  String get explore => 'Explore';

  @override
  String get logout => 'Log out';

  @override
  String get homeFeed => 'Home Feed';

  @override
  String get currentlyWatching => 'Currently watching';

  @override
  String get seeMore => 'See More';

  @override
  String get likedPieces => 'Liked Pieces';

  @override
  String get topLikedPieces => 'Top liked pieces';

  @override
  String get favouriteArtists => 'Favourite Artists';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String piecesCount(int count) {
    return '$count pieces';
  }

  @override
  String get searchByPieceAuthorType => 'Search by piece, author, or type';

  @override
  String get all => 'All';

  @override
  String get audio => 'Audio';

  @override
  String get text => 'Text';

  @override
  String get picture => 'Picture';

  @override
  String get audioDuration => 'Audio duration';

  @override
  String get readingTime => 'Reading time';

  @override
  String get anyDuration => 'Any duration';

  @override
  String get underFiveMinutes => 'Under 5 min';

  @override
  String get fiveToFifteenMinutes => '5–15 min';

  @override
  String get overFifteenMinutes => 'Over 15 min';

  @override
  String get anyReadingTime => 'Any reading time';

  @override
  String get noRecommendations => 'No recommendations match your filters.';

  @override
  String get createdPieces => 'Created Pieces';

  @override
  String get piecesInDevelopment => 'Pieces in Development';

  @override
  String get createNewArtPiece => 'Create New Art Piece';

  @override
  String get definitions => 'Definitions';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get friends => 'Friends';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get settingsSubtitle => 'Manage email, password, account, and logout.';

  @override
  String get publishedPiecesSubtitle => 'View your published art pieces.';

  @override
  String get draftsSubtitle => 'Continue working on your drafts.';

  @override
  String get createPieceSubtitle => 'Start a picture, audio, or text piece.';

  @override
  String get accountDetailsSubtitle =>
      'Edit your profile, picture, description, and language.';

  @override
  String get friendsSubtitle => 'View your friends list.';

  @override
  String get friendRequestsSubtitle => 'Review people who want to connect.';

  @override
  String get pleaseLogIn => 'Please log in to view your area.';

  @override
  String get pleaseLogInAgain => 'Please log in again.';

  @override
  String get noFriends => 'Your friends will appear here.';

  @override
  String get noFriendRequests => 'You have no pending friend requests.';

  @override
  String get searchEmpty => 'No results found';

  @override
  String get authorProfile => 'Author Profile';

  @override
  String get artistProfile => 'Artist profile';

  @override
  String get createdPiecesProfile => 'Created pieces';

  @override
  String viewPublishedWork(Object name) {
    return 'View $name\'s published work';
  }

  @override
  String get likesAcrossPublishedPieces =>
      'Likes earned across published pieces';

  @override
  String get addFriend => 'Add friend';

  @override
  String get friendRequestSent => 'Friend request sent.';

  @override
  String get friendRequestFailed => 'Could not send the friend request.';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get friendRequestAccepted => 'Friend request accepted.';

  @override
  String get friendRequestRejected => 'Friend request rejected.';

  @override
  String get viewProfile => 'View profile';

  @override
  String get removeFriend => 'Remove friend';

  @override
  String get removeFriendConfirmation =>
      'Are you sure you want to remove this friend?';

  @override
  String get friendRemoved => 'Friend removed.';

  @override
  String get remove => 'Remove';

  @override
  String get chat => 'Message';

  @override
  String get writeMessage => 'Write a message';

  @override
  String get send => 'Send';

  @override
  String get viewPublishedPieces => 'View your published art pieces.';

  @override
  String get continueDrafts => 'Continue working on your drafts.';

  @override
  String get artPieceCreatedSuccessfully => 'Art piece created successfully.';

  @override
  String get noDraftsYet => 'You have no drafts yet.';

  @override
  String get noPublishedPiecesYet => 'You have not published any pieces yet.';

  @override
  String get loading => 'Loading…';

  @override
  String get loadPiecesError => 'Could not load your pieces. Please try again.';

  @override
  String get noPiecesAvailable => 'No pieces are available right now.';

  @override
  String get noComments => 'No comments yet.';

  @override
  String get writeComment => 'Write a comment';

  @override
  String get addComment => 'Add comment';

  @override
  String get commentsLoadFailed => 'Could not load comments.';

  @override
  String get commentFailed => 'Could not add the comment.';

  @override
  String totalLikes(int count) {
    return '$count total likes';
  }

  @override
  String get totalLikesLabel => 'Total likes';

  @override
  String get seeComments => 'See Comments';

  @override
  String translateTo(Object language) {
    return 'Translate to $language';
  }

  @override
  String get showOriginal => 'Show Original';

  @override
  String get listenToAudio => 'Listen to Audio';

  @override
  String get stopAudio => 'Stop Audio';

  @override
  String get playAudio => 'Play Audio';

  @override
  String get pauseAudio => 'Pause Audio';

  @override
  String get readText => 'Read Text';

  @override
  String get hideText => 'Hide Text';

  @override
  String formatNotSupported(Object format) {
    return 'Format $format is not natively supported';
  }

  @override
  String get invalidBase64 => 'This media has invalid Base64 data.';

  @override
  String get unsupportedAudio =>
      'Unsupported audio format. Expected MP3, FLAC, or M4A.';

  @override
  String get audioInitFailed => 'Audio could not be initialized.';

  @override
  String get textToSpeechUnavailable => 'Text-to-speech is unavailable.';

  @override
  String get loadingMedia => 'Loading media…';

  @override
  String get createArtPiece => 'Create Art Piece';

  @override
  String get whatCreating => 'What are you creating?';

  @override
  String get published => 'Published';

  @override
  String get publish => 'Publish';

  @override
  String get publishDraftConfirmation =>
      'Are you sure you want to publish this draft?';

  @override
  String get publishedSuccessfully => 'Draft published successfully.';

  @override
  String get inDevelopment => 'In Development';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get textContent => 'Text content';

  @override
  String get saveArtPiece => 'Save Art Piece';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takePicture => 'Take a picture';

  @override
  String get chooseAudioFile => 'Choose audio file';

  @override
  String get recordAudio => 'Record audio';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get changeProfilePicture => 'Change profile picture';

  @override
  String get username => 'Username';

  @override
  String get language => 'Language';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get logIn => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get needAccount => 'Need an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get passwordMin => 'Use at least 6 characters';

  @override
  String get emailRequired => 'Enter your email';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get microphonePermissionRequired =>
      'Microphone permission is required to record audio.';

  @override
  String get audioSizeGuidance => 'Keep recordings under 2 minutes and 700 KB.';

  @override
  String get audioTooLarge =>
      'This audio is larger than 700 KB. Choose a shorter or smaller file.';

  @override
  String get mediaContentRequired => 'Add the required media content first.';

  @override
  String get textContentRequired => 'Add some text.';

  @override
  String get savePieceFailed => 'Could not save this piece';

  @override
  String get pictureReady => 'Picture ready (compressed to Base64).';

  @override
  String get audioReady => 'Audio ready for preview.';

  @override
  String audioBytes(int count) {
    return '$count bytes';
  }

  @override
  String get insertImageBase64 => 'Insert optional image as Base64';

  @override
  String get interleavedImageNotice =>
      'The optional image will be interleaved with the text as Base64.';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deletePiece => 'Delete piece?';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get deletePieceFailed => 'Could not delete this piece.';

  @override
  String get cannotLikeOwnPiece => 'You cannot like your own art piece.';

  @override
  String get likeFailed => 'Could not like this piece.';

  @override
  String get profileSetup => 'Set up your profile';

  @override
  String get addProfilePictureOptional => 'Add profile picture (optional)';

  @override
  String get shortDescriptionOptional => 'Short description (optional)';

  @override
  String get finish => 'Finish';

  @override
  String get imageLoadFailed => 'Could not load that image.';

  @override
  String get profileSaveFailed =>
      'Could not save your profile. Please try again.';

  @override
  String get createAccount => 'Create account';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get invalidCredentials => 'The email or password is incorrect.';

  @override
  String get accountAlreadyExists =>
      'An account already exists for this email.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get authenticationFailed => 'Authentication failed. Please try again.';

  @override
  String get resetEmailSent => 'Password reset email sent.';

  @override
  String get credits => 'Credits';

  @override
  String get creditsMenuSubtitle => 'About the app and its creator.';

  @override
  String get creditsCreatedBy => 'Created by';

  @override
  String get creditsRepository => 'GitHub Repository';

  @override
  String get creditsOpenSource =>
      'ArteX is an open-source project. Contributions are welcome!';

  @override
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get suggestionsMenuSubtitle => 'Send ideas to improve ArteX.';

  @override
  String get suggestionsTitle => 'Share Your Ideas';

  @override
  String get suggestionsSubtitle =>
      'Have a suggestion or feature request? We\'d love to hear from you!';

  @override
  String get suggestionLabel => 'Your suggestion';

  @override
  String get suggestionHint => 'Describe your idea or improvement...';

  @override
  String get suggestionRequired => 'Please write your suggestion first.';

  @override
  String get suggestionSend => 'Send Suggestion';

  @override
  String get suggestionSentSuccess =>
      'Suggestion sent successfully. Thank you!';

  @override
  String get suggestionSentFailed =>
      'Could not send your suggestion. Please try again.';
}
