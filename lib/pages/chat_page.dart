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

  // List<String> dmIds = [];

  // Stream<List<String>> getDMIdsStream() {
  //   return db
  //       .collection('userData')
  //       .doc(userId)
  //       .snapshots()
  //       .map((event) => List<String>.from(event['dmId']));
  // }

  // sort chat rooms by latest time
  void sortChatRooms() {
    // chatRooms.sort((a, b) => b['latest_time'].compareTo(a['latest_time']));
  }

  @override
  void initState() {
    super.initState();
    // getDMIdsStream().listen((ids) {
    //   setState(() {
    //     dmIds = ids;
    //   });
    // });
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
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 5),
                itemCount: dmNames.length,
                itemBuilder: (BuildContext context, int index) {
                  final chatRoom = capitalize(dmNames[index]);
                  // final chatRoomId = chatRoom.id;
                  // final chatRoomName = chatRoom['name'];
                  // final chatRoomType = chatRoom['type'];
                  // final chatRoomLatestMessage = chatRoom['latest_message'];
                  // final chatRoomLatestTime = chatRoom['latest_time'];

                  // if (chatRoomType == 'dm') {
                  //   if (dmIds.contains(chatRoomId)) {
                  //     return ChatTile(
                  //       name: chatRoomName,
                  //       type: chatRoomType,
                  //       latest_message: chatRoomLatestMessage,
                  //       latest_time: chatRoomLatestTime,
                  //     );
                  //   }
                  // } else {
                  //   return ChatTile(
                  //     name: chatRoomName,
                  //     type: chatRoomType,
                  //     latest_message: chatRoomLatestMessage,
                  //     latest_time: chatRoomLatestTime,
                  //   );
                  // }
                  return ChatTile(
                      name: chatRoom,
                      type: 'dm',
                      latest_message: 'latest_message',
                      latest_time: DateTime.now());
                },
              );
            },
          ),
        ),
        // Expanded(
        //   child: ListView.builder(
        //     padding: EdgeInsets.symmetric(vertical: 5),
        //     itemCount: chatRooms.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       return ChatTile(
        //         name: chatRooms[index]['name'],
        //         type: chatRooms[index]['type'],
        //         latest_message: chatRooms[index]['latest_message'],
        //         latest_time: chatRooms[index]['latest_time'],
        //       );
        //     },
        //   ),
        // ),
      ]),
    );
  }
}
