// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAbZ5bsiF-j7dFBUfoGUTx3Y1Nv35a2YPc',
    appId: '1:164017588711:web:3f07f5fab942cfa3095542',
    messagingSenderId: '164017588711',
    projectId: 'stockmarket-5d5a2',
    authDomain: 'stockmarket-5d5a2.firebaseapp.com',
    storageBucket: 'stockmarket-5d5a2.firebasestorage.app',
    measurementId: 'G-08LJHD2EVM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnUqUxrk2soBixFlVlBZgBzC9MfcOjANI',
    appId: '1:164017588711:android:393b07d389e90475095542',
    messagingSenderId: '164017588711',
    projectId: 'stockmarket-5d5a2',
    storageBucket: 'stockmarket-5d5a2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1_nrc4qbu3hq0yBqPWXHcBOsoq9QYN64',
    appId: '1:164017588711:ios:882f1a39b8cc151c095542',
    messagingSenderId: '164017588711',
    projectId: 'stockmarket-5d5a2',
    storageBucket: 'stockmarket-5d5a2.firebasestorage.app',
    iosBundleId: 'com.example.stockapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1_nrc4qbu3hq0yBqPWXHcBOsoq9QYN64',
    appId: '1:164017588711:ios:882f1a39b8cc151c095542',
    messagingSenderId: '164017588711',
    projectId: 'stockmarket-5d5a2',
    storageBucket: 'stockmarket-5d5a2.firebasestorage.app',
    iosBundleId: 'com.example.stockapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAbZ5bsiF-j7dFBUfoGUTx3Y1Nv35a2YPc',
    appId: '1:164017588711:web:ad09111a42d260c4095542',
    messagingSenderId: '164017588711',
    projectId: 'stockmarket-5d5a2',
    authDomain: 'stockmarket-5d5a2.firebaseapp.com',
    storageBucket: 'stockmarket-5d5a2.firebasestorage.app',
    measurementId: 'G-Y476BN3VE8',
  );
}
