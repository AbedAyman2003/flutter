import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مع الإعدادات اليدوية
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "1:885403099080:android:d9cc6d9a6ee5af12f32afd",
      appId: "1:123456789012:android:abcdef1234567890",
      messagingSenderId: "123456789012",
      projectId: "appfirebase1-5519f",
      databaseURL: "https://appfirebase1-5519f-default-rtdb.firebaseio.com/",
      storageBucket: "appfirebase1-5519f.firebasestorage.app",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Database - Users',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UsersScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}