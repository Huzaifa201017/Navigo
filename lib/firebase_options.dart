// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBY6Edl2J8S8WUUlNwSNAU5tvyzlQpjV20',
    appId: '1:617458806919:android:c7d3e05671542169750822',
    messagingSenderId: '617458806919',
    projectId: 'navigo-55abb',
    storageBucket: 'navigo-55abb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAOe-ZkEF7Tz9gg_Qiph37GMz8gzY2L20',
    appId: '1:617458806919:ios:acd35b0f82472f83750822',
    messagingSenderId: '617458806919',
    projectId: 'navigo-55abb',
    storageBucket: 'navigo-55abb.appspot.com',
    androidClientId: '617458806919-jq0h8beh7vgkd67tvalg6cql5muoqjpd.apps.googleusercontent.com',
    iosClientId: '617458806919-ds9i8ctgk3nturcm6i0d36d7iqoamn1s.apps.googleusercontent.com',
    iosBundleId: 'com.example.navigo',
  );
}
