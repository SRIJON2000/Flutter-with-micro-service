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
        return macos;
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
    apiKey: 'AIzaSyCHrYTWqRnpfbQ6WSFJHuRfM4j8rCvI1Dg',
    appId: '1:512851274229:web:678409048dbffd5b6458bc',
    messagingSenderId: '512851274229',
    projectId: 'quick-shift-5657c',
    authDomain: 'quick-shift-5657c.firebaseapp.com',
    storageBucket: 'quick-shift-5657c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgrmohmbX-11sUHFObkFvjLMjhERSxRNM',
    appId: '1:512851274229:android:e468fe220038e8d36458bc',
    messagingSenderId: '512851274229',
    projectId: 'quick-shift-5657c',
    storageBucket: 'quick-shift-5657c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCddVqYbEut4kuxzEsEim2vkK26HuamhuY',
    appId: '1:512851274229:ios:7576d3fd461866c36458bc',
    messagingSenderId: '512851274229',
    projectId: 'quick-shift-5657c',
    storageBucket: 'quick-shift-5657c.appspot.com',
    androidClientId: '512851274229-i4n3hma26m8v2410psd8p7e9jmmk4sj2.apps.googleusercontent.com',
    iosClientId: '512851274229-qd9k9ee450rbm869oa6ecuqfluf849ts.apps.googleusercontent.com',
    iosBundleId: 'com.example.quickShift',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCddVqYbEut4kuxzEsEim2vkK26HuamhuY',
    appId: '1:512851274229:ios:7576d3fd461866c36458bc',
    messagingSenderId: '512851274229',
    projectId: 'quick-shift-5657c',
    storageBucket: 'quick-shift-5657c.appspot.com',
    androidClientId: '512851274229-i4n3hma26m8v2410psd8p7e9jmmk4sj2.apps.googleusercontent.com',
    iosClientId: '512851274229-qd9k9ee450rbm869oa6ecuqfluf849ts.apps.googleusercontent.com',
    iosBundleId: 'com.example.quickShift',
  );
}
