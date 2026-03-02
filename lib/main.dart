import 'package:flutter/material.dart';
import 'package:primaa/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyBOXjassEJcUIFCgffBwEwsSDm-w2coeDo",
    authDomain: "suivi-des-bateaux.firebaseapp.com",
    projectId: "suivi-des-bateaux",
    storageBucket: "suivi-des-bateaux.firebasestorage.app",
    messagingSenderId: "731759035788",
    appId: "1:731759035788:web:b0b9d8073058ddcd3a82a9",
  ),);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          debugShowCheckedModeBanner:false, 
          home: const Splashscreen(),
    );
  }
}

