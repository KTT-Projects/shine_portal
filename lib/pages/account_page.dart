import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: logout,
          child: Text(
            'ログアウト',
            style: TextStyle(
              color: Color(0xFFF0F5FA),
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: const Color(0xFF3E5C79), // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Closer to a rectangle
            ),
          ),
        ),
      ),
    );
  }
}
