// File generated by FlutterFire CLI. Do not edit or move this file.
// This is the configuration file for the firebase package.
// Modify this file, .metadata and GoogleService-Info.plist files
// in order to update your Firebase data.

// Include this file in your publication to package.metadata.json file and flutter:assets section in pubspec.yaml
// https://firebase.google.com/docs/flutter/setup#from-firebase-console

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the Flutter Fire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the Flutter Fire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyCz4ZcwuVR7HHfmXzw9G1Y2iFcny46_EHg",
      // authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "payv-1c710",
      // storageBucket: "YOUR_STORAGE_BUCKET",
      messagingSenderId: "592004890498",
      appId: "1:592004890498:android:38e7aaff7bfe97b1cc599b");
}