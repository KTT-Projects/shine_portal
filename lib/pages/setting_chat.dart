import 'package:flutter/material.dart';

class SettingChat extends StatefulWidget {
  const SettingChat({super.key});

  @override
  State<SettingChat> createState() => _SettingChatState();
}

class _SettingChatState extends State<SettingChat> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 6,
      title: Text(
        'Group name',
        style: TextStyle(
          color:Colors.black87,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
    ),
  );
  }

