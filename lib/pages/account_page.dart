import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final user = FirebaseAuth.instance.currentUser!;
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    String userId = capitalize(user.email!.replaceAll('@shine.com', ''));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3E5C79),
                  Color(0xC03E5C79),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Image.asset(
              'lib/images/logo.png',
              width: 250,
            ),
          ),
          SizedBox(height: 10),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xC03E5C79),
                Color(0xFF3E5C79),
                Color(0xC03E5C79),
              ],
              tileMode: TileMode.mirror,
            ).createShader(bounds),
            child: Text(
              'シャインポータル',
              style: GoogleFonts.dotGothic16(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'サポート: info@kttprojects.com',
            style: TextStyle(
              color: Color(0x951C1D21),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'ログアウト',
              style: TextStyle(
                color: Color(0xFFF0F5FA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
