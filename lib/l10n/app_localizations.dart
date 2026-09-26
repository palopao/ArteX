import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Artex'**
  String get appTitle;

  /// No description provided for @welcomeToArtex.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Artex'**
  String get welcomeToArtex;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myArea.
  ///
  /// In en, this message translates to:
  /// **'My Area'**
  String get myArea;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @homeFeed.
  ///
  /// In en, this message translates to:
  /// **'Home Feed'**
  String get homeFeed;

  /// No description provided for @currentlyWatching.
  ///
  /// In en, this message translates to:
  /// **'Currently watching'**
  String get currentlyWatching;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @likedPieces.
  ///
  /// In en, this message translates to:
  /// **'Liked Pieces'**
  String get likedPieces;

  /// No description provided for @topLikedPieces.
  ///
  /// In en, this message translates to:
  /// **'Top liked pieces'**
  String get topLikedPieces;

  /// No description provided for @favouriteArtists.
  ///
  /// In en, this message translates to:
  /// **'Favourite Artists'**
  String get favouriteArtists;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @piecesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pieces'**
  String piecesCount(int count);

  /// No description provided for @searchByPieceAuthorType.
  ///
  /// In en, this message translates to:
  /// **'Search by piece, author, or type'**
  String get searchByPieceAuthorType;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @picture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get picture;

  /// No description provided for @audioDuration.
  ///
  /// In en, this message translates to:
  /// **'Audio duration'**
  String get audioDuration;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'Reading time'**
  String get readingTime;

  /// No description provided for @anyDuration.
  ///
  /// In en, this message translates to:
  /// **'Any duration'**
  String get anyDuration;

  /// No description provided for @underFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'Under 5 min'**
  String get underFiveMinutes;

  /// No description provided for @fiveToFifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'5–15 min'**
  String get fiveToFifteenMinutes;

  /// No description provided for @overFifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'Over 15 min'**
  String get overFifteenMinutes;

  /// No description provided for @anyReadingTime.
  ///
  /// In en, this message translates to:
  /// **'Any reading time'**
  String get anyReadingTime;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations match your filters.'**
  String get noRecommendations;

  /// No description provided for @createdPieces.
  ///
  /// In en, this message translates to:
  /// **'Created Pieces'**
  String get createdPieces;

  /// No description provided for @piecesInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Pieces in Development'**
  String get piecesInDevelopment;

  /// No description provided for @createNewArtPiece.
  ///
  /// In en, this message translates to:
  /// **'Create New Art Piece'**
  String get createNewArtPiece;

  /// No description provided for @definitions.
  ///
  /// In en, this message translates to:
  /// **'Definitions'**
  String get definitions;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage email, password, account, and logout.'**
  String get settingsSubtitle;

  /// No description provided for @publishedPiecesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your published art pieces.'**
  String get publishedPiecesSubtitle;

  /// No description provided for @draftsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue working on your drafts.'**
  String get draftsSubtitle;

  /// No description provided for @createPieceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a picture, audio, or text piece.'**
  String get createPieceSubtitle;

  /// No description provided for @accountDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile, picture, description, and language.'**
  String get accountDetailsSubtitle;

  /// No description provided for @friendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your friends list.'**
  String get friendsSubtitle;

  /// No description provided for @friendRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review people who want to connect.'**
  String get friendRequestsSubtitle;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your area.'**
  String get pleaseLogIn;

  /// No description provided for @pleaseLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please log in again.'**
  String get pleaseLogInAgain;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'Your friends will appear here.'**
  String get noFriends;

  /// No description provided for @noFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'You have no pending friend requests.'**
  String get noFriendRequests;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchEmpty;

  /// No description provided for @authorProfile.
  ///
  /// In en, this message translates to:
  /// **'Author Profile'**
  String get authorProfile;

  /// No description provided for @artistProfile.
  ///
  /// In en, this message translates to:
  /// **'Artist profile'**
  String get artistProfile;

  /// No description provided for @createdPiecesProfile.
  ///
  /// In en, this message translates to:
  /// **'Created pieces'**
  String get createdPiecesProfile;

  /// No description provided for @viewPublishedWork.
  ///
  /// In en, this message translates to:
  /// **'View {name}\'s published work'**
  String viewPublishedWork(Object name);

  /// No description provided for @likesAcrossPublishedPieces.
  ///
  /// In en, this message translates to:
  /// **'Likes earned across published pieces'**
  String get likesAcrossPublishedPieces;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriend;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent.'**
  String get friendRequestSent;

  /// No description provided for @friendRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the friend request.'**
  String get friendRequestFailed;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted.'**
  String get friendRequestAccepted;

  /// No description provided for @friendRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected.'**
  String get friendRequestRejected;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get removeFriend;

  /// No description provided for @removeFriendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this friend?'**
  String get removeFriendConfirmation;

  /// No description provided for @friendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed.'**
  String get friendRemoved;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get writeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @viewPublishedPieces.
  ///
  /// In en, this message translates to:
  /// **'View your published art pieces.'**
  String get viewPublishedPieces;

  /// No description provided for @continueDrafts.
  ///
  /// In en, this message translates to:
  /// **'Continue working on your drafts.'**
  String get continueDrafts;

  /// No description provided for @artPieceCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Art piece created successfully.'**
  String get artPieceCreatedSuccessfully;

  /// No description provided for @noDraftsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no drafts yet.'**
  String get noDraftsYet;

  /// No description provided for @noPublishedPiecesYet.
  ///
  /// In en, this message translates to:
  /// **'You have not published any pieces yet.'**
  String get noPublishedPiecesYet;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @loadPiecesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your pieces. Please try again.'**
  String get loadPiecesError;

  /// No description provided for @noPiecesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No pieces are available right now.'**
  String get noPiecesAvailable;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noComments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get writeComment;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get addComment;

  /// No description provided for @commentsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load comments.'**
  String get commentsLoadFailed;

  /// No description provided for @commentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the comment.'**
  String get commentFailed;

  /// No description provided for @totalLikes.
  ///
  /// In en, this message translates to:
  /// **'{count} total likes'**
  String totalLikes(int count);

  /// No description provided for @totalLikesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total likes'**
  String get totalLikesLabel;

  /// No description provided for @seeComments.
  ///
  /// In en, this message translates to:
  /// **'See Comments'**
  String get seeComments;

  /// No description provided for @translateTo.
  ///
  /// In en, this message translates to:
  /// **'Translate to {language}'**
  String translateTo(Object language);

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show Original'**
  String get showOriginal;

  /// No description provided for @listenToAudio.
  ///
  /// In en, this message translates to:
  /// **'Listen to Audio'**
  String get listenToAudio;

  /// No description provided for @stopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop Audio'**
  String get stopAudio;

  /// No description provided for @playAudio.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get playAudio;

  /// No description provided for @pauseAudio.
  ///
  /// In en, this message translates to:
  /// **'Pause Audio'**
  String get pauseAudio;

  /// No description provided for @readText.
  ///
  /// In en, this message translates to:
  /// **'Read Text'**
  String get readText;

  /// No description provided for @hideText.
  ///
  /// In en, this message translates to:
  /// **'Hide Text'**
  String get hideText;

  /// No description provided for @formatNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Format {format} is not natively supported'**
  String formatNotSupported(Object format);

  /// No description provided for @invalidBase64.
  ///
  /// In en, this message translates to:
  /// **'This media has invalid Base64 data.'**
  String get invalidBase64;

  /// No description provided for @unsupportedAudio.
  ///
  /// In en, this message translates to:
  /// **'Unsupported audio format. Expected MP3, FLAC, or M4A.'**
  String get unsupportedAudio;

  /// No description provided for @audioInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Audio could not be initialized.'**
  String get audioInitFailed;

  /// No description provided for @textToSpeechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech is unavailable.'**
  String get textToSpeechUnavailable;

  /// No description provided for @loadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Loading media…'**
  String get loadingMedia;

  /// No description provided for @createArtPiece.
  ///
  /// In en, this message translates to:
  /// **'Create Art Piece'**
  String get createArtPiece;

  /// No description provided for @whatCreating.
  ///
  /// In en, this message translates to:
  /// **'What are you creating?'**
  String get whatCreating;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @publishDraftConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to publish this draft?'**
  String get publishDraftConfirmation;

  /// No description provided for @publishedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Draft published successfully.'**
  String get publishedSuccessfully;

  /// No description provided for @inDevelopment.
  ///
  /// In en, this message translates to:
  /// **'In Development'**
  String get inDevelopment;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @textContent.
  ///
  /// In en, this message translates to:
  /// **'Text content'**
  String get textContent;

  /// No description provided for @saveArtPiece.
  ///
  /// In en, this message translates to:
  /// **'Save Art Piece'**
  String get saveArtPiece;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takePicture;

  /// No description provided for @chooseAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Choose audio file'**
  String get chooseAudioFile;

  /// No description provided for @recordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get recordAudio;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get changeProfilePicture;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

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

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @needAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign up'**
  String get needAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get passwordMin;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record audio.'**
  String get microphonePermissionRequired;

  /// No description provided for @audioSizeGuidance.
  ///
  /// In en, this message translates to:
  /// **'Keep recordings under 2 minutes and 700 KB.'**
  String get audioSizeGuidance;

  /// No description provided for @audioTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This audio is larger than 700 KB. Choose a shorter or smaller file.'**
  String get audioTooLarge;

  /// No description provided for @mediaContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Add the required media content first.'**
  String get mediaContentRequired;

  /// No description provided for @textContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Add some text.'**
  String get textContentRequired;

  /// No description provided for @savePieceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this piece'**
  String get savePieceFailed;

  /// No description provided for @pictureReady.
  ///
  /// In en, this message translates to:
  /// **'Picture ready (compressed to Base64).'**
  String get pictureReady;

  /// No description provided for @audioReady.
  ///
  /// In en, this message translates to:
  /// **'Audio ready for preview.'**
  String get audioReady;

  /// No description provided for @audioBytes.
  ///
  /// In en, this message translates to:
  /// **'{count} bytes'**
  String audioBytes(int count);

  /// No description provided for @insertImageBase64.
  ///
  /// In en, this message translates to:
  /// **'Insert optional image as Base64'**
  String get insertImageBase64;

  /// No description provided for @interleavedImageNotice.
  ///
  /// In en, this message translates to:
  /// **'The optional image will be interleaved with the text as Base64.'**
  String get interleavedImageNotice;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePiece.
  ///
  /// In en, this message translates to:
  /// **'Delete piece?'**
  String get deletePiece;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletePieceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this piece.'**
  String get deletePieceFailed;

  /// No description provided for @cannotLikeOwnPiece.
  ///
  /// In en, this message translates to:
  /// **'You cannot like your own art piece.'**
  String get cannotLikeOwnPiece;

  /// No description provided for @likeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not like this piece.'**
  String get likeFailed;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get profileSetup;

  /// No description provided for @addProfilePictureOptional.
  ///
  /// In en, this message translates to:
  /// **'Add profile picture (optional)'**
  String get addProfilePictureOptional;

  /// No description provided for @shortDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Short description (optional)'**
  String get shortDescriptionOptional;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @imageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load that image.'**
  String get imageLoadFailed;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Please try again.'**
  String get profileSaveFailed;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get accountAlreadyExists;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authenticationFailed;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetEmailSent;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditsMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About the app and its creator.'**
  String get creditsMenuSubtitle;

  /// No description provided for @creditsCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get creditsCreatedBy;

  /// No description provided for @creditsRepository.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get creditsRepository;

  /// No description provided for @creditsOpenSource.
  ///
  /// In en, this message translates to:
  /// **'ArteX is an open-source project. Contributions are welcome!'**
  String get creditsOpenSource;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @suggestionsMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send ideas to improve ArteX.'**
  String get suggestionsMenuSubtitle;

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Ideas'**
  String get suggestionsTitle;

  /// No description provided for @suggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have a suggestion or feature request? We\'d love to hear from you!'**
  String get suggestionsSubtitle;

  /// No description provided for @suggestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion'**
  String get suggestionLabel;

  /// No description provided for @suggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your idea or improvement...'**
  String get suggestionHint;

  /// No description provided for @suggestionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write your suggestion first.'**
  String get suggestionRequired;

  /// No description provided for @suggestionSend.
  ///
  /// In en, this message translates to:
  /// **'Send Suggestion'**
  String get suggestionSend;

  /// No description provided for @suggestionSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent successfully. Thank you!'**
  String get suggestionSentSuccess;

  /// No description provided for @suggestionSentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send your suggestion. Please try again.'**
  String get suggestionSentFailed;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

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
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
