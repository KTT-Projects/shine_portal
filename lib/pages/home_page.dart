import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.email!.replaceAll('@shine.com', '');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('signed in as: $userId'),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.blue,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 20, top: 10, left: 20, right: 20),
          child: GNav(
            haptic: true,
            tabBorderRadius: 35,
            tabBackgroundColor: const Color(0x2F3E5C79),
            duration: const Duration(milliseconds: 300),
            gap: 10,
            tabs: [
              const GButton(
                icon: Icons.home,
                text: 'ホーム',
              ),
              const GButton(
                icon: Icons.chat,
                text: 'チャット',
              ),
              const GButton(
                icon: Icons.notifications,
                text: '通知',
              ),
              GButton(
                icon: Icons.person,
                text: userId,
              ),
            ],
            selectedIndex: 0,
            onTabChange: (index) {},
          ),
        ),
      ),
    );
  }
}
