import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  // Prevent concurrent button presses
  bool _waiting = false; // Added loading state

  Future login() async {
    setState(() {
      _waiting = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: LoadingAnimationWidget.inkDrop(
              color: const Color(0xC03E5C79),
              size: 50,
            ),
          ),
        );
      },
    );
    String email = '${_idController.text.trim()}@shine.com';
    String password = _passwordController.text.trim();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'too-many-requests') {
        errorMessage =
            'このアカウントはロックされました。\n時間を置いてから再度お試しいただくか、\ninfo@kttprojects.comにお問い合わせください。';
      } else if (e.code == 'invalid-credential' ||
          e.code == 'invalid-email' ||
          e.code == 'wrong-password') {
        errorMessage = 'ユーザーIDまたはパスワードが間違っています';
      } else {
        errorMessage =
            'エラーが発生しました。\n時間を置いてから再度お試しいただくか、\ninfo@kttprojects.comにお問い合わせください。';
      }
      // Immediately hide the previous error
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
    Navigator.of(context).pop();
    setState(() {
      _waiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
<<<<<<< HEAD
          child: Container(
            width: 500,
=======
          child: SizedBox(
            width: 430,
>>>>>>> origin/calendar
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ShaderMask(
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
                  ),
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
                      'シャインポータルへようこそ',
                      style: GoogleFonts.dotGothic16(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'IDとパスワードを以下の欄に入力してください',
                    style: TextStyle(
                      color: Color(0x951C1D21),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'ユーザーID',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'パスワード',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _waiting ? null : login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          backgroundColor:
                              const Color(0xFF3E5C79), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Closer to a rectangle
                          ),
                        ),
                        child: const Text(
                          'ログイン',
                          style: TextStyle(
                            color: Color(0xFFF0F5FA),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
