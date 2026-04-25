import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web options are not configured for Klaro yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase iOS options are not configured for Klaro yet.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase macOS options are not configured for Klaro yet.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase Windows options are not configured for Klaro yet.',
        );
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
}
