import 'package:comp_499_senior_project/firebase_options.dart';
import 'package:comp_499_senior_project/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures binding is initialized before Firebase

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  /*
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "sign-speak-app-aff74",
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCFIhlfmLI5wn-tQik3O8eerPDzhCPypx4',
        appId: '1:330383229148:android:c147743a94600d7762f419',
        messagingSenderId: '330383229148',
        projectId: 'sign-speak-app-aff74',
        storageBucket: 'sign-speak-app-aff74.firebasestorage.app',
      ),
    );
    print("Firebase initialized successfully"); // Initialize Firebase
  }
   */
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  runApp(SignSpeakApp(showOnboarding: showOnboarding));
}

class SignSpeakApp extends StatelessWidget {
  final bool showOnboarding;
  const SignSpeakApp({Key? key, required this.showOnboarding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign-Speak Communication Assistant',
      themeMode: ThemeMode.dark, // Set the theme mode to dark
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            Colors.grey[800], // Set background color for all screens
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800], // AppBar background color
          titleTextStyle: TextStyle(
            color: Colors.white, // AppBar title text color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white), // AppBar icons color
        ),
        cardColor: Colors.grey[900], // Card background color
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Default body text color
          bodyMedium: TextStyle(color: Colors.white), // Smaller text color
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue, // Default button background color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Elevated button color
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white), // Input label text color
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.white), // Border color for enabled inputs
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Border color for focused inputs
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
