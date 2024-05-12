import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class IndividualChatRoom extends StatefulWidget {
  final String name, dmId;
  final int chatIndex;
  const IndividualChatRoom({
    super.key,
    required this.name,
    required this.dmId,
    required this.chatIndex,
  });

  @override
  IndividualChatRoomState createState() => IndividualChatRoomState();
}

class IndividualChatRoomState extends State<IndividualChatRoom> {
  String userId =
      FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');
  final List<types.Message> _databaseMessages = [];
  final _user = const types.User(id: '');
  int? lastSeenWhenOpened;
  types.Message? _sendingMessage;

  void _addMessage(String author, String message, String id, final time) {
    final types.TextMessage textMessage;
    if (author == widget.name.toLowerCase()) {
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

  //他のユーザーの情報を取得
  types.User get _other => types.User(
        id: widget.name,
        firstName: widget.name,
      );

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
          title: Text(
            widget.name,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black87,
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: db.collection('dm').snapshots(),
            builder: (context, snapshot) {
              _databaseMessages.clear();
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final messages = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == widget.dmId)['messages']);
              final sender = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == widget.dmId)['sender']);
              final time = List<Timestamp>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == widget.dmId)['time']);
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
                    final dmLastSeen = List<int>.from(snapshot.data!.docs
                        .firstWhere((doc) => doc.id == userId)['dmLastSeen']);
                    lastSeenWhenOpened ??= dmLastSeen[widget.chatIndex];
                    dmLastSeen[widget.chatIndex] = messages.length;
                    db.collection('userData').doc(userId).update({
                      'dmLastSeen': dmLastSeen,
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
    db.collection('dm').doc(widget.dmId).get().then((doc) {
      final messages = List<String>.from(doc.data()!['messages']);
      final sender = List<String>.from(doc.data()!['sender']);
      final time = List<Timestamp>.from(doc.data()!['time']);

      messages.add(textMessage.text);
      sender.add(userId);
      time.add(Timestamp.fromDate(DateTime.now()));

      db.collection('dm').doc(widget.dmId).update({
        'messages': messages,
        'sender': sender,
        'time': time,
      });
    });
  }
}
