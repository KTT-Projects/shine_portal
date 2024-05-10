import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shine_portal/pages/account_page.dart';
import 'package:shine_portal/pages/calendar_page.dart';
import 'package:shine_portal/pages/chat_page.dart';
import 'package:shine_portal/pages/notifications_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  // Function to navigate the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Capitalize the first letter of a string
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // List of pages to display in the bottom bar
  final List<Widget> pages = [
    const CalendarPage(),
    const ChatPage(),
    const NotificationsPage(),
    const AccountPage(),
  ];

  final TextEditingController _searchFieldController = TextEditingController();
  String _searchFieldValue = '';
  final db = FirebaseFirestore.instance;
  String userId =
      FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');

  Future addUser() async {
    _searchFieldValue = _searchFieldController.text;
    CollectionReference userData = db.collection('userData');
    final docRef = userData.doc(userId);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      // add userdata if it does not exist
      userData.doc(userId).set({
        'dm': [],
        'group': [],
        'dmId': [],
        'dmLastSeen': [],
        'groupLastSeen': [],
      });
    }
  }

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    addUser();
  }

  Future<void> fetchSuggestions() async {
    QuerySnapshot querySnapshot = await db.collection('userData').get();
    List<String> documentNames = [];
    querySnapshot.docs.forEach((doc) {
      String documentName = doc.id;
      if (documentName != userId) {
        documentNames.add(documentName);
      }
    });
    setState(() {
      suggestions = documentNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFFF0F5FA),
      ),
      backgroundColor: const Color(0xFFF0F5FA),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 10,
            left: 20,
            right: 20,
          ),
          child: GNav(
            haptic: true,
            tabBorderRadius: 35,
            tabBackgroundColor: const Color(0x2F3E5C79),
            duration: const Duration(milliseconds: 300),
            gap: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            padding: const EdgeInsets.all(20),
            tabs: [
              const GButton(
                icon: Icons.home,
                text: 'ホーム', // Home tab
              ),
              const GButton(
                icon: Icons.chat,
                text: 'チャット', // Chat tab
              ),
              const GButton(
                icon: Icons.notifications,
                text: '通知', // Notifications tab
              ),
              GButton(
                icon: Icons.person,
                text: capitalize(userId), // User's name tab
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
