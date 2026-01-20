import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const androidConfig = FirebaseOptions(
    apiKey: "1:885403099080:android:d9cc6d9a6ee5af12f32afd",
    appId: "1:123456789012:android:abcdef1234567890",
    messagingSenderId: "123456789012",
    projectId: "appfirebase1-5519f",
    databaseURL: "https://appfirebase1-5519f-default-rtdb.firebaseio.com/",
    storageBucket: "appfirebase1-5519f.firebasestorage.app",
  );

  static const iosConfig = FirebaseOptions(
    apiKey: "AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZ123456789",
    appId: "1:123456789012:ios:abcdef1234567890",
    messagingSenderId: "123456789012",
    projectId: "your-project-id",
    databaseURL: "https://your-project-id.firebaseio.com",
    storageBucket: "your-project-id.appspot.com",
    iosBundleId: "com.example.app",
  );
}