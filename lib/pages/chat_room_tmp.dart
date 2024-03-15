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

class GroupChatRoom extends StatefulWidget {
  final String name;
  GroupChatRoom({
    Key? key,
    required this.name,
  });

  @override
  GroupChatRoomState createState() => GroupChatRoomState();
}

class GroupChatRoomState extends State<GroupChatRoom> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '');

  //他のユーザーの情報を取得
  types.User get _other => types.User(
        id: widget.name,
        firstName: widget.name,
      );

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
        appBar: AppBar(
          backgroundColor: Color(0xFFF0F5FA),
          title: Text(widget.name),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: Chat(
          // 追加
          theme: const DefaultChatTheme(
              backgroundColor: Color(0xFFF0F5FA),
              primaryColor: Color(0xFF3E5C79), // メッセージの背景色の変更
              userAvatarNameColors: [Colors.black87], // ユーザー名の文字色の変更
              sentMessageDocumentIconColor: Colors.black87,
              secondaryColor: Color(0xFFFFFFFF),
              inputBackgroundColor: Color(0xFFFFFFFF),
              inputTextColor: Color(0xFF1C1D21)),
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
