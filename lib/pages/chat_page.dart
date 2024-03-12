import 'package:flutter/material.dart';
import 'chat_room.dart';
import 'package:shine_portal/pages/components/create_chat.dart';

// A page for creating chat rooms.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Creates a dialog for selecting the chat type.
  void createChatRoom() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CreateChat();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        ElevatedButton(
          onPressed: createChatRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E5C79),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
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
        )
      ]),
    );
  }
}
