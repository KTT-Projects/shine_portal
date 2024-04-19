import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shine_portal/pages/components/chat_tile.dart';
import 'package:shine_portal/pages/components/create_chat.dart';

// A page for creating chat rooms.
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

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

  // Capitalize the first letter of a string
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  final user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  String userId =
      FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');

  @override
  void initState() {
    super.initState();
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
          child: StreamBuilder<QuerySnapshot>(
            stream: db.collection('userData').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('エラーが発生しました');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final dmIds = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == userId)['dmId']);
              final dmNames = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == userId)['dm']);
              final groupIds = List<String>.from(snapshot.data!.docs
                  .firstWhere((doc) => doc.id == userId)['group']);

              if (dmIds.isEmpty && groupIds.isEmpty) {
                return const Center(
                  child: Text('まだチャットルームがありません'),
                );
              } else {
                // Get the latest message and time from DMs
                return StreamBuilder<QuerySnapshot>(
                    stream: db.collection('userData').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('エラーが発生しました');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final chatRooms = [];
                      return StreamBuilder<QuerySnapshot>(
                        stream: db.collection('dm').snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('エラーが発生しました');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final chatRooms = [];
                          for (var index = 0; index < dmNames.length; index++) {
                            final chatRoom = {
                              'dmId': dmIds[index],
                              'message': snapshot.data!.docs
                                  .firstWhere((doc) => doc.id == dmIds[index])[
                                      'messages']
                                  .last,
                              'time': snapshot.data!.docs
                                  .firstWhere(
                                      (doc) => doc.id == dmIds[index])['time']
                                  .last,
                              'name': capitalize(dmNames[index]),
                              'type': 'dm',
                            };
                            chatRooms.add(chatRoom);
                          }

                          // Get the latest message and time from groups
                          return StreamBuilder<QuerySnapshot>(
                              stream: db.collection('group').snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('エラーが発生しました');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                for (var index = 0;
                                    index < groupIds.length;
                                    index++) {
                                  final chatRoom = {
                                    'groupId': groupIds[index],
                                    'message': snapshot.data!.docs
                                        .firstWhere((doc) =>
                                            doc.id ==
                                            groupIds[index])['messages']
                                        .last,
                                    'time': snapshot.data!.docs
                                        .firstWhere((doc) =>
                                            doc.id == groupIds[index])['time']
                                        .last,
                                    'name': snapshot.data!.docs.firstWhere(
                                        (doc) =>
                                            doc.id == groupIds[index])['name'],
                                    'type': 'group',
                                  };
                                  for (var index = 0;
                                      index < groupIds.length;
                                      index++) {
                                    final chatRoom = {
                                      'groupId': groupIds[index],
                                      'message': snapshot.data!.docs
                                          .firstWhere((doc) =>
                                              doc.id ==
                                              groupIds[index])['messages']
                                          .last,
                                      'time': snapshot.data!.docs
                                          .firstWhere((doc) =>
                                              doc.id == groupIds[index])['time']
                                          .last,
                                      'name': snapshot.data!.docs.firstWhere(
                                          (doc) =>
                                              doc.id ==
                                              groupIds[index])['name'],
                                      'type': 'group',
                                    };

                                    // Check if the chat room already exists
                                    final existingChatRoomIndex =
                                        chatRooms.indexWhere((room) =>
                                            room['groupId'] == groupIds[index]);
                                    if (existingChatRoomIndex != -1) {
                                      // Update the existing chat room
                                      chatRooms[existingChatRoomIndex] =
                                          chatRoom;
                                    } else {
                                      // Add the new chat room
                                      chatRooms.add(chatRoom);
                                    }
                                  }
                                  // chatRooms.add(chatRoom);
                                }
                                chatRooms.sort(
                                    (a, b) => b['time'].compareTo(a['time']));
                                return ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  itemCount: dmNames.length + groupIds.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final chatRoom = chatRooms[index];
                                    return ChatTile(
                                        name: chatRoom['name'],
                                        type: chatRoom['type'],
                                        latest_message: chatRoom['message'],
                                        latest_time:
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                chatRoom['time']
                                                    .microsecondsSinceEpoch),
                                        chatId: chatRoom['type'] == 'dm'
                                            ? chatRoom['dmId']
                                            : chatRoom['groupId']);
                                  },
                                );
                              });
                        },
                      );
                    });
              }
            },
          ),
        ),
      ]),
    );
  }
}
