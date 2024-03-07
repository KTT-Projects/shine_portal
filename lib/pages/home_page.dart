import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shine_portal/pages/account_page.dart';
import 'package:shine_portal/pages/calendar_page.dart';
import 'package:shine_portal/pages/chat_page.dart';
import 'package:shine_portal/pages/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List pages = [
    const CalendarPage(),
    const ChatPage(),
    const NotificationsPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    String userId = user.email!.replaceAll('@shine.com', '');

    return Scaffold(
      body: pages[_selectedIndex],
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
            selectedIndex: _selectedIndex,
            onTabChange: (index) => navigateBottomBar(index),
          ),
        ),
      ),
    );
  }
}
