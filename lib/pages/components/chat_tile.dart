import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shine_portal/pages/chat_room.dart';

class ChatTile extends StatefulWidget {
  final String name;
  final String type;
  final String latest_message;
  final DateTime latest_time;
  Function(BuildContext)? deleteChat;

  ChatTile({
    super.key,
    required this.name,
    required this.type,
    required this.latest_message,
    required this.latest_time,
    this.deleteChat,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  final now = DateTime.now();
  String formattedTime = '';

  Widget build(BuildContext context) {
    final now = DateTime.now();
    String formattedTime = '';

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (widget.latest_time.isAfter(today)) {
      formattedTime = 'Today ${DateFormat('HH:mm').format(widget.latest_time)}';
    } else if (widget.latest_time.isAfter(yesterday)) {
      formattedTime =
          'Yesterday ${DateFormat('HH:mm').format(widget.latest_time)}';
    } else if (widget.latest_time.year == now.year) {
      formattedTime = DateFormat('MMM d, HH:mm').format(widget.latest_time);
    } else {
      formattedTime =
          DateFormat('MMM d, yyyy, HH:mm').format(widget.latest_time);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: widget.deleteChat,
            icon: Icons.delete,
            backgroundColor: Colors.red.shade300,
            borderRadius: BorderRadius.circular(12),
          )
        ]),
        child: GestureDetector(
          onTap: () {
            // Navigate to the chat page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IndivisualChatRoom(name: widget.name),
              ),
            );
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
                        // child: Icon(Icons.person),
                        child: Icon(
                          widget.type == 'dm' ? Icons.person : Icons.group,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.latest_message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(
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

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement the chat page UI
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
      ),
      body: Center(
        child: Text('Chat Page'),
      ),
    );
  }
}
