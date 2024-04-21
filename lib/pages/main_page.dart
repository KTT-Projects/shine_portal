import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shine_portal/pages/home_page.dart';
import 'package:shine_portal/pages/login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if user is authenticated
          if (snapshot.hasData) {
            // If authenticated, show home page
            return const HomePage();
          } else {
            // If not authenticated, show login page
            return const LoginPage();
          }
        },
      ),
    );
  }
}
