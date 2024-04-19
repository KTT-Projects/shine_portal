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
  Function(BuildContext)? deleteChat;

  ChatTile({
    super.key,
    required this.name,
    required this.type,
    required this.latest_message,
    required this.latest_time,
    required this.chatId,
    this.deleteChat,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
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
    final formatted_message = widget.latest_message.length > 30
        ? '${widget.latest_message.substring(0, 30)}…'
        : widget.latest_message;

    final formatted_chat_name = widget.name.length > 20
        ? '${widget.name.substring(0, 20)}…'
        : widget.name;

    // Format the time based on the message's timestamp
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
        endActionPane: ActionPane(motion: const StretchMotion(), children: [
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
            if (widget.type == 'dm') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualChatRoom(
                    name: widget.name,
                    dmId: widget.chatId,
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
