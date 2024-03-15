import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:shine_portal/pages/setting_chat.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({Key? key}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<GroupChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');


//他のユーザーの情報を取得
  final _other = const types.User(
      id: 'otheruser',
      firstName: "テスト",
      lastName: "test",
  );

@override
  void initState() {
    super.initState();
    _addMessage(types.TextMessage(
      author: _other,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "テストです。",
      status: types.Status.delivered,
    ));
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 6,
      title: Text(
        'User name',
        style: TextStyle(
          color:Colors.black87,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
      actions: [
          IconButton(
            icon: Icon(Icons.density_medium),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingChat()),
            );
            },
          ),
        ],
    ),
        body: Chat(
          theme: const DefaultChatTheme(
            backgroundColor: Color(0xFFF0F5FA),
            primaryColor: Color(0xFF3E5C79),  // メッセージの背景色の変更
            userAvatarNameColors: [Colors.black87],  // ユーザー名の文字色の変更
            sentMessageDocumentIconColor: Color.fromARGB(221, 49, 32, 32),
            secondaryColor: Color(0xFFFFFFFF),
            inputBackgroundColor: Color(0xFFFFFFFF),
            inputTextColor: Color(0xFF1C1D21)
          ),
          user: _user,
          messages: _messages,
          onSendPressed: _handleSendPressed,
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
