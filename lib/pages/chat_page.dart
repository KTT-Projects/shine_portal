import 'package:flutter/material.dart';
import 'package:shine_portal/pages/components/chat_tile.dart';
import 'chat_room.dart';
import 'package:shine_portal/pages/components/create_chat.dart';
import 'package:shine_portal/pages/group_chat_page.dart';


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

  List chatRooms = [
    {
      'name': 'Tasuku',
      'type': 'dm',
      'latest_message': 'こんにちは！',
      'latest_time': DateTime.now().subtract(Duration(days: 1)),
    },
    {
      'name': 'パーティー',
      'type': 'group',
      'latest_message': 'みなさん、こんにちは',
      'latest_time': DateTime(2021, 10, 10, 10, 10),
    },
    {
      'name': 'Tomoki',
      'type': 'dm',
      'latest_message': 'やあ！',
      'latest_time': DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      'name': '仕事',
      'type': 'group',
      'latest_message': '2時にミーティング',
      'latest_time': DateTime.now().subtract(Duration(minutes: 30)),
    },
    {
      'name': 'Kuzuki',
      'type': 'dm',
      'latest_message': 'おはよう！',
      'latest_time': DateTime.now().subtract(Duration(days: 2)),
    },
    {
      'name': '家族',
      'type': 'group',
      'latest_message': 'みんな元気？',
      'latest_time': DateTime.now().subtract(Duration(hours: 1)),
    },
    {
      'name': 'Hayato',
      'type': 'dm',
      'latest_message': '明日暇？',
      'latest_time': DateTime.now().subtract(Duration(days: 3)),
    },
    {
      'name': '友達',
      'type': 'group',
      'latest_message': '旅行の計画しよう！',
      'latest_time': DateTime.now().subtract(Duration(days: 1, hours: 6)),
    },
    {
      'name': 'Rikuta',
      'type': 'dm',
      'latest_message': '久しぶり！',
      'latest_time': DateTime.now().subtract(Duration(days: 1, hours: 12)),
    },
    {
      'name': '勉強グループ',
      'type': 'group',
      'latest_message': '課題を忘れずに',
      'latest_time': DateTime.now().subtract(Duration(days: 2, hours: 4)),
    },
  ];

  // sort chat rooms by latest time
  void sortChatRooms() {
    chatRooms.sort((a, b) => b['latest_time'].compareTo(a['latest_time']));
  }

  @override
  void initState() {
    super.initState();
    sortChatRooms();
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
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 5),
            itemCount: chatRooms.length,
            itemBuilder: (BuildContext context, int index) {
              return ChatTile(
                name: chatRooms[index]['name'],
                type: chatRooms[index]['type'],
                latest_message: chatRooms[index]['latest_message'],
                latest_time: chatRooms[index]['latest_time'],
              );
            },
          ),
        ),
      ]),
    );
  }
}
