import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
          'Firebase Linux options are not configured for Klaro yet.',
        );
      default:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUmDHivTTNv_ouxuexJslFnDK6I3gSi1o',
    appId: '1:510975278553:android:3f5d826962f57203b7adc8',
    messagingSenderId: '510975278553',
    projectId: 'klaro-851a6',
    storageBucket: 'klaro-851a6.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCYVvdmr2OzJWuMti2_s7q5WIR1kPQDoEM',
    appId: '1:510975278553:web:e3ccd81f109e87a5b7adc8',
    messagingSenderId: '510975278553',
    projectId: 'klaro-851a6',
    authDomain: 'klaro-851a6.firebaseapp.com',
    storageBucket: 'klaro-851a6.firebasestorage.app',
    measurementId: 'G-K2BS0LBFK0',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvSrTg3GxblGs5yYw7ga_0nCBUES5kqJE',
    appId: '1:510975278553:ios:2a48645c2267c896b7adc8',
    messagingSenderId: '510975278553',
    projectId: 'klaro-851a6',
    storageBucket: 'klaro-851a6.firebasestorage.app',
    iosBundleId: 'com.example.klaro',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvSrTg3GxblGs5yYw7ga_0nCBUES5kqJE',
    appId: '1:510975278553:ios:2a48645c2267c896b7adc8',
    messagingSenderId: '510975278553',
    projectId: 'klaro-851a6',
    storageBucket: 'klaro-851a6.firebasestorage.app',
    iosBundleId: 'com.example.klaro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCYVvdmr2OzJWuMti2_s7q5WIR1kPQDoEM',
    appId: '1:510975278553:web:dd0bb3690c881a6fb7adc8',
    messagingSenderId: '510975278553',
    projectId: 'klaro-851a6',
    authDomain: 'klaro-851a6.firebaseapp.com',
    storageBucket: 'klaro-851a6.firebasestorage.app',
    measurementId: 'G-Y4KHGN2MYD',
  );

}