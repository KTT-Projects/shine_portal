import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(),
                backgroundColor: Color(0xFF3E5C79),
              ),
              child: Container(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'チャットルームを作成',
                    style: TextStyle(
                      color: Color(0xFFF0F5FA),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
