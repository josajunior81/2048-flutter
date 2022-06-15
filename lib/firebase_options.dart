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
    apiKey: 'AIzaSyBc19-eJ0G1BRHH3p2o-9DlFfgSRf5I5uo',
    appId: '1:584702851287:web:5890524a75f6d137e35892',
    messagingSenderId: '584702851287',
    projectId: 'project-7104572225695465188',
    authDomain: 'project-7104572225695465188.firebaseapp.com',
    storageBucket: 'project-7104572225695465188.appspot.com',
    measurementId: 'G-6BJMZ2Z8X3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSEWgwrgCeMjefEzLH_7ECwqv34y3kBN0',
    appId: '1:584702851287:android:e92274112dad3d45e35892',
    messagingSenderId: '584702851287',
    projectId: 'project-7104572225695465188',
    storageBucket: 'project-7104572225695465188.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVw8oq00HEIq08EHZoAofUwvGFHHm63M8',
    appId: '1:584702851287:ios:ab53e22f67cec6f9e35892',
    messagingSenderId: '584702851287',
    projectId: 'project-7104572225695465188',
    storageBucket: 'project-7104572225695465188.appspot.com',
    iosClientId: '584702851287-u3lua0322s6a1j51mvarovu985quqvdf.apps.googleusercontent.com',
    iosBundleId: 'com.jojun.game2048',
  );
}
