import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
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
          'DefaultFirebaseOptions have not been configured for $defaultTargetPlatform - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACm6u3CSvjuJyJNoSDHAIC4RdtDDY9OYY',
    appId: '1:865008490628:ios:be0477c9b337abc9b60ad1',
    messagingSenderId: '865008490628',
    projectId: 'mobile-store-mangment',
    storageBucket: 'mobile-store-mangment.firebasestorage.app',
    iosBundleId: 'com.example.phoneStoreMangment',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYoepZf89fqmuCqfcmIxPP2KvQSWnRLuA',
    appId: '1:865008490628:android:bb7d311efb9e01f5b60ad1',
    messagingSenderId: '865008490628',
    projectId: 'mobile-store-mangment',
    storageBucket: 'mobile-store-mangment.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdqWaOQS8Q5rd2VHUthlbFTcAH0Tj1slo',
    appId: '1:865008490628:web:dcd1b7d5e7e12ec4b60ad1',
    messagingSenderId: '865008490628',
    projectId: 'mobile-store-mangment',
    authDomain: 'mobile-store-mangment.firebaseapp.com',
    storageBucket: 'mobile-store-mangment.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACm6u3CSvjuJyJNoSDHAIC4RdtDDY9OYY',
    appId: '1:865008490628:ios:be0477c9b337abc9b60ad1',
    messagingSenderId: '865008490628',
    projectId: 'mobile-store-mangment',
    storageBucket: 'mobile-store-mangment.firebasestorage.app',
    iosBundleId: 'com.example.phoneStoreMangment',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAdqWaOQS8Q5rd2VHUthlbFTcAH0Tj1slo',
    appId: '1:865008490628:web:9996fa767894e98bb60ad1',
    messagingSenderId: '865008490628',
    projectId: 'mobile-store-mangment',
    authDomain: 'mobile-store-mangment.firebaseapp.com',
    storageBucket: 'mobile-store-mangment.firebasestorage.app',
  );

}