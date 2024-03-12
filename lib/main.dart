import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shine_portal/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter is initialized before calling Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set the color scheme for the app
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C79)),
        // Set the font family for the app using Google Fonts
        fontFamily: GoogleFonts.mPlus1p().fontFamily,
      ),
      // Set the home page of the app
      home: const MainPage(),
    );
  }
}
