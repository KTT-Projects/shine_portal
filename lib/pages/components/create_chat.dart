import 'package:flutter/material.dart';
import 'package:shine_portal/pages/components/create_dm.dart';

class CreateChat extends StatefulWidget {
  const CreateChat({super.key});

  @override
  State<CreateChat> createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'チャットタイプを選択してください',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            // Add border radius to the list tile.
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            leading: const Icon(Icons.person),
            title: const Text(
              '個人',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            onTap: () {
              // Handle the tap.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateDm(),
                ),
              );
            },
          ),
          ListTile(
            // Add border radius to the list tile.
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            leading: const Icon(Icons.group),
            title: const Text(
              'グループ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            onTap: () {
              // Handle the tap.
            },
          ),
        ],
      ),
    );
  }
}
