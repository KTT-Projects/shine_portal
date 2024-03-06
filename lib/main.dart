import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shine_portal/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C79)),
        fontFamily: GoogleFonts.mPlus1p().fontFamily,
      ),
      home: const MainPage(),
    );
  }
}
