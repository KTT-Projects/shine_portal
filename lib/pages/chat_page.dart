import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  void createChatRoom() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'チャットタイプを選択してください',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  '個人',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  // Handle the tap
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text(
                  'グループ',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  // Handle the tap
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: createChatRoom,
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                backgroundColor: const Color(0xFF3E5C79),
              ),
              child: const SizedBox(
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
