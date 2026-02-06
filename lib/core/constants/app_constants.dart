/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Running Club Tunis';
  static const String appShortName = 'RCT';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Application officielle du Running Club Tunis';

  // Association Info
  static const String clubFoundedDate = '21 Avril 2016';
  static const String clubAddress = '39, Rue Ali Ayari El Menzeh 9A 1013';
  static const String clubPhone = '24474474';
  static const String clubEmail = 'runningclubtunis@gmail.com';
  static const String clubWebsite = 'runningclubtunis.blogspot.com';
  static const String clubInstagram =
      'https://instagram.com/running_club_tunis';
  static const String clubFacebook = 'https://www.facebook.com/rctunis/';

  // API
  static const String stravaClientId = 'YOUR_STRAVA_CLIENT_ID';
  static const String stravaClientSecret = 'YOUR_STRAVA_CLIENT_SECRET';
  static const String stravaRedirectUri = 'rctapp://strava-callback';
  static const String stravaAuthUrl = 'https://www.strava.com/oauth/authorize';
  static const String stravaTokenUrl = 'https://www.strava.com/oauth/token';
  static const String stravaApiBase = 'https://www.strava.com/api/v3';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String eventsCollection = 'events';
  static const String mediaCollection = 'media';
  static const String notesCollection = 'notes';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String programsCollection = 'programs';
  static const String notificationsCollection = 'notifications';
  static const String classementCollection = 'classement';
  static const String clubInfoCollection = 'clubInfo';

  // Storage Paths
  static const String profilePhotosPath = 'profiles';
  static const String eventMediaPath = 'events';
  static const String thumbnailsPath = 'thumbnails';
  static const String documentsPath = 'documents';

  // Limits
  static const int maxPhotoUploadMB = 10;
  static const int maxVideoUploadMB = 50;
  static const int maxReelDurationSec = 60;
  static const int maxPhotosPerUpload = 10;
  static const int paginationLimit = 20;
  static const int stravaMatchWindowMinutes = 120;

  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';

  // Accessibility
  static const double minTouchTarget = 48.0;
  static const double minContrastRatio = 4.5;
}
