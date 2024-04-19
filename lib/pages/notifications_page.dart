import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('下のURLにて開発ロードマップを公開しています'),
          SizedBox(height: 10),
          Link(
            uri: Uri.parse('https://shine-portal.kttprojects.com/roadmap'),
            builder: (context, followLink) {
              return InkWell(
                onTap: followLink,
                child: Text(
                  'https://shine-portal.kttprojects.com/roadmap',
                  style: TextStyle(color: Color(0xFF3E5C79)),
                ),
              );
            },
          ),
          // InkWell(
          //   child: Text('https://shine-portal.kttprojects.com/roadmap'),
          //   onTap: () async {
          //     if (await canLaunch(
          //         'https://shine-portal.kttprojects.com/roadmap')) {
          //       await launch('https://shine-portal.kttprojects.com/roadmap');
          //     }
          //   },
          // )
        ],
      )),
    );
  }
}
