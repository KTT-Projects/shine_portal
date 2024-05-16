import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:shine_portal/pages/chat_settings.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  int chatIndex = 0;
  String name;
  GroupChatPage({
    Key? key,
    required this.name,
    required this.groupId,
    required this.chatIndex,
  });

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<GroupChatPage> {
  String userId =
      FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');
  List<types.Message> _databaseMessages = [];
  final _user = const types.User(id: '');
  int? lastSeenWhenOpened;
  types.Message? _sendingMessage;

  // Capitalize the first letter of a string
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _addMessage(String author, String message, String id, final time) {
    // Define the other user
    final _other = types.User(
      id: author,
      firstName: capitalize(author),
    );
    final types.TextMessage textMessage;
    if (author != userId) {
      textMessage = types.TextMessage(
        author: _other,
        createdAt: time.toDate().millisecondsSinceEpoch,
        id: id,
        text: message,
      );
    } else {
      textMessage = types.TextMessage(
        author: _user,
        createdAt: time.toDate().millisecondsSinceEpoch,
        id: id,
        text: message,
      );
    }
    _databaseMessages.insert(0, textMessage);
  }

  @override
  void initState() {
    super.initState();
  }

  final user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF0F5FA),
          title: StreamBuilder<QuerySnapshot>(
              stream: db.collection('group').snapshots(),
              builder: (context, snapshot) {
                widget.name = snapshot.data!.docs
                    .firstWhere((doc) => doc.id == widget.groupId)['name'];
                return Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                );
              }),
          iconTheme: const IconThemeData(
            color: Colors.black87,
          ),
          actions: [
            StreamBuilder<QuerySnapshot>(
                stream: db.collection('group').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final users = List<String>.from(snapshot.data!.docs
                      .firstWhere((doc) => doc.id == widget.groupId)['users']);
                  return IconButton(
                    icon: const Icon(Icons.density_medium),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatSettings(
                                  name: widget.name,
                                  groupId: widget.groupId,
                                  users: users,
                                )),
                      );
                    },
                  );
                }),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: db.collection('group').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              _databaseMessages.clear();
              final messages = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == widget.groupId)['messages']);
              final sender = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == widget.groupId)['sender']);
              final time = List<Timestamp>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == widget.groupId)['time']);
              for (var i = 0;
                  i < min(messages.length, min(sender.length, time.length));
                  i++) {
                _addMessage(
                    sender[i], messages[i], (i + 1).toString(), time[i]);
              }
              return StreamBuilder<QuerySnapshot>(
                  stream: db.collection('userData').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // set last seen to the number of messages
                    final groupLastSeen = List<int>.from(snapshot.data!.docs
                        .firstWhere(
                            (doc) => doc.id == userId)['groupLastSeen']);
                    lastSeenWhenOpened ??= groupLastSeen[widget.chatIndex];
                    groupLastSeen[widget.chatIndex] = messages.length;
                    db.collection('userData').doc(userId).update({
                      'groupLastSeen': groupLastSeen,
                    });
                    final List<types.Message> finalMessages = [];
                    finalMessages.addAll(_databaseMessages);
                    if (_sendingMessage != null) {
                      for (var i = 0; i < finalMessages.length; i++) {
                        if (finalMessages[i].id == _sendingMessage!.id) {
                          _sendingMessage = null;
                          break;
                        }
                      }
                      if (_sendingMessage != null) {
                        finalMessages.insert(0, _sendingMessage!);
                      }
                    }
                    return Chat(
                      theme: const DefaultChatTheme(
                          backgroundColor: Color(0xFFF0F5FA),
                          primaryColor: Color(0xFF3E5C79), // メッセージの背景色の変更
                          userAvatarNameColors: [
                            Colors.black87
                          ], // ユーザー名の文字色の変更
                          sentMessageDocumentIconColor:
                              Color.fromARGB(221, 49, 32, 32),
                          secondaryColor: Color(0xFFFFFFFF),
                          inputBackgroundColor: Color(0xFFFFFFFF),
                          inputTextColor: Color(0xFF1C1D21)),
                      user: _user,
                      messages: finalMessages,
                      onSendPressed: _handleSendPressed,
                      showUserAvatars: true,
                      showUserNames: true,
                      scrollToUnreadOptions: ScrollToUnreadOptions(
                        lastReadMessageId: lastSeenWhenOpened.toString(),
                        scrollOnOpen: true,
                      ),
                      l10n: const ChatL10nEn(
                        inputPlaceholder: 'メッセージを入力',
                        unreadMessagesLabel: '未読メッセージ',
                      ),
                      isAttachmentUploading: _sendingMessage != null,
                      inputOptions: InputOptions(
                        inputClearMode: _sendingMessage != null
                            ? InputClearMode.never
                            : InputClearMode.always,
                      ),
                    );
                  });
              // });
            }),
      );

  void _handleSendPressed(types.PartialText message) {
    if (_sendingMessage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('メッセージ送信中'),
            content: const Text('前のメッセージが送信されるまでお待ちください。'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: (_databaseMessages.length + 1).toString(),
      text: message.text,
      status: types.Status.sending,
    );
    setState(() {
      lastSeenWhenOpened = _databaseMessages.length + 1;
      _sendingMessage = textMessage;
    });
    db.collection('group').doc(widget.groupId).get().then((doc) {
      final messages = List<String>.from(doc.data()!['messages']);
      final sender = List<String>.from(doc.data()!['sender']);
      final time = List<Timestamp>.from(doc.data()!['time']);

      messages.add(textMessage.text);
      sender.add(userId);
      time.add(Timestamp.fromDate(DateTime.now()));

      db.collection('group').doc(widget.groupId).update({
        'messages': messages,
        'sender': sender,
        'time': time,
      });
    });
  }
}
