import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class IndivisualChatRoom extends StatefulWidget {
  const IndivisualChatRoom({super.key});

  @override
  IndivisualChatRoomState createState() => IndivisualChatRoomState();
}

class IndivisualChatRoomState extends State<IndivisualChatRoom> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

//他のユーザーの情報を取得
  final _other = const types.User(
      id: 'otheruser',
      firstName: "テスト",
      lastName: "太郎",
      imageUrl:
          "https://pbs.twimg.com/profile_images/1335856760972689408/Zeyo7jdq_bigger.jpg");

  @override
    void initState() {
      super.initState();
      _addMessage(types.TextMessage(
        author: _other,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: "テストです。",
    ));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          showUserAvatars: true,
          showUserNames: true,
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }
}
