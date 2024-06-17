import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shine_portal/pages/chat_room.dart';
import 'package:shine_portal/pages/group_chat_page.dart';

class ChatTile extends StatefulWidget {
  final String name;
  final String type;
  final String latest_message;
  final DateTime latest_time;
  final String chatId;
  final int chatIndex;
  // Function(BuildContext)? deleteChat;

  ChatTile({
    super.key,
    required this.name,
    required this.type,
    required this.latest_message,
    required this.latest_time,
    required this.chatId,
    required this.chatIndex,
    // required this.deleteChat,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

final user = FirebaseAuth.instance.currentUser!;
final db = FirebaseFirestore.instance;
String userId = FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');

// delete chat when deletion button is pressed
void deleteChat(BuildContext context, String chatId, int chatIndex, String type) {
  if (type == 'dm') {
    String otherUser = '';
    db.collection('userData').doc(userId).get().then((doc) {
      otherUser = doc['dm'][chatIndex];
      db.collection('userData').doc(otherUser).update({
        'dm': FieldValue.arrayRemove([userId]),
        'dmId': FieldValue.arrayRemove([chatId]),
      });
    });
    db.collection('dm').doc(chatId).delete();
    db.collection('userData').doc(userId).update({
      'dm': FieldValue.arrayRemove([otherUser]),
      'dmId': FieldValue.arrayRemove([chatId]),
    });
  } else {
    List<String> users = [];
    db.collection('group').doc(chatId).get().then((doc) {
      users = List<String>.from(doc['users']);
      for (var user in users) {
        db.collection('userData').doc(user).update({
          'group': FieldValue.arrayRemove([chatId]),
        });
      }
    });
    db.collection('group').doc(chatId).delete();
    for (var user in users) {
      db.collection('userData').doc(user).update({
        'group': FieldValue.arrayRemove([chatId]),
      });
    }
  }
  Navigator.of(context).pop();
}

class _ChatTileState extends State<ChatTile> {
  final now = DateTime.now();
  String formattedTime = '';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String formattedTime = '';

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // Truncate the latest message if it's longer than 13 characters
    final formatted_message = widget.latest_message.length > 30 ? '${widget.latest_message.substring(0, 30)}…' : widget.latest_message;

    final formatted_chat_name = widget.name.length > 20 ? '${widget.name.substring(0, 20)}…' : widget.name;

    // Format the time based on the message's timestamp
    if (widget.latest_time.isAfter(today)) {
      formattedTime = '今日 ${DateFormat('HH:mm').format(widget.latest_time)}';
    } else if (widget.latest_time.isAfter(yesterday)) {
      formattedTime = '昨日 ${DateFormat('HH:mm').format(widget.latest_time)}';
    } else if (widget.latest_time.year == now.year) {
      formattedTime = DateFormat('MMM d, HH:mm').format(widget.latest_time);
    } else {
      formattedTime = DateFormat('MMM d, yyyy, HH:mm').format(widget.latest_time);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
      child: Slidable(
        endActionPane: ActionPane(motion: const StretchMotion(), children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('チャットルームを削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteChat(context, widget.chatId, widget.chatIndex, widget.type);
                        },
                        child: const Text('削除'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icons.delete,
            backgroundColor: Colors.red.shade300,
            borderRadius: BorderRadius.circular(12),
          )
        ]),
        child: GestureDetector(
          onTap: () {
            // Navigate to the chat page
            if (widget.type == 'dm') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualChatRoom(
                    name: widget.name,
                    dmId: widget.chatId,
                    chatIndex: widget.chatIndex,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatPage(
                    name: widget.name,
                    groupId: widget.chatId,
                    chatIndex: widget.chatIndex,
                  ),
                ),
              );
            }
          },
          child: Card(
            color: const Color(0xFFF0F5FA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        // Display different icons based on the chat type
                        child: Icon(
                          widget.type == 'dm' ? Icons.person : Icons.group,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 170,
                            child: Text(
                              formatted_chat_name,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 170,
                            child: Text(
                              formatted_message,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
