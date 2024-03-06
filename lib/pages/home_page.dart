import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // appBar: ,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('signed in as: $userId'),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Text('Sign out'),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
