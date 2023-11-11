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
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCh1JXX3tFZs3LKBxSxd8mCx-bIfCHvNCM',
    appId: '1:426590177970:web:816db203b21766e8ff17ab',
    messagingSenderId: '426590177970',
    projectId: 'fitnc-7be2e',
    authDomain: 'fitnc-7be2e.firebaseapp.com',
    storageBucket: 'fitnc-7be2e.appspot.com',
    measurementId: 'G-JKV6SZSDMW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5-fe7LI55gdrhRx5E7LvNsRdchBgXkV0',
    appId: '1:426590177970:android:8547b9fa39f9759fff17ab',
    messagingSenderId: '426590177970',
    projectId: 'fitnc-7be2e',
    storageBucket: 'fitnc-7be2e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCPlkUdKNX6oNpCTYjWhcO8J_ZpSQ9cv-c',
    appId: '1:426590177970:ios:0ce39749372de3f7ff17ab',
    messagingSenderId: '426590177970',
    projectId: 'fitnc-7be2e',
    storageBucket: 'fitnc-7be2e.appspot.com',
    androidClientId: '426590177970-46519nv2j29vpf5lljn6u46pbk37o137.apps.googleusercontent.com',
    iosClientId: '426590177970-360h0l96cm7le3gf5r88gdss8rsljps4.apps.googleusercontent.com',
    iosBundleId: 'nc.deveo.fitncFrontendFlutter',
  );
}