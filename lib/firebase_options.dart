import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAMlqmfqjinFGLHLE9j18-keICSohp99Jw',
    appId: '1:631713688963:web:placeholder_web_app_id', // Needs valid web app id
    messagingSenderId: '631713688963',
    projectId: 'shopspot-influencer',
    authDomain: 'shopspot-influencer.firebaseapp.com',
    storageBucket: 'shopspot-influencer.firebasestorage.app',
    measurementId: 'G-placeholder',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMlqmfqjinFGLHLE9j18-keICSohp99Jw',
    appId: '1:631713688963:android:775a2eaf09f5b1308bdab6',
    messagingSenderId: '631713688963',
    projectId: 'shopspot-influencer',
    storageBucket: 'shopspot-influencer.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXhrwo-_Lhxt2BahFWrt3xqTcCwFNMuT4',
    appId: '1:631713688963:ios:f30d90aa06d83e068bdab6',
    messagingSenderId: '631713688963',
    projectId: 'shopspot-influencer',
    storageBucket: 'shopspot-influencer.firebasestorage.app',
    iosBundleId: 'com.mobile.shopspot',
  );
}
