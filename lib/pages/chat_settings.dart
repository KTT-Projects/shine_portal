import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:searchfield/searchfield.dart';

class ChatSettings extends StatefulWidget {
  final String name, groupId;
  final List<String> users;
  const ChatSettings({
    super.key,
    required this.name,
    required this.groupId,
    required this.users,
  });

  @override
  State<ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchFieldController = TextEditingController();
  final TextEditingController _textFieldController = TextEditingController();
  String _searchFieldValue = '';
  String _textFieldValue = '';
  final db = FirebaseFirestore.instance;
  String userId =
      FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');
  bool isLoading = false; // Added loading state
  List users = [];

  Future add_user() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    bool flag = false;
    _searchFieldValue = _searchFieldController.text;
    if (_searchFieldValue == '') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ユーザー名を入力してください',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      return;
    }
    // check whether name is in suggestion
    for (var value in suggestions) {
      if (value.toLowerCase() == _searchFieldValue.toLowerCase()) {
        flag = true;
      }
    }
    if (!flag) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ユーザーが見つかりませんでした',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      return;
    }
    if (users.contains(_searchFieldValue.toLowerCase())) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'このユーザーはすでに追加されています',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      return;
    }
    users.add(_searchFieldValue.toLowerCase());
    _searchFieldController.clear(); // Clear the search field
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  Future modify_group() async {
    _textFieldValue = _textFieldController.text;
    setState(() {
      isLoading = true; // Show loading indicator
    });

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ユーザーを追加してください',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      return;
    }
    // Check if group name is empty
    if (_textFieldController.text.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'グループ名を入力してください',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      return;
    }
    users.add(userId);
    List messages, sender, time, usersList, newUsers = [], deletedUsers = [];
    bool flag = false;
    db.collection('group').doc(widget.groupId).get().then((doc) {
      messages = List<String>.from(doc.data()!['messages']);
      sender = List<String>.from(doc.data()!['sender']);
      time = List<Timestamp>.from(doc.data()!['time']);
      usersList = List<String>.from(doc.data()!['users']);
      String name = doc.data()!['name'];

      // Check for new users
      for (var user in users) {
        if (!usersList.contains(user)) {
          newUsers.add(user);
        }
      }

      // Check for deleted users
      for (var user in usersList) {
        if (!users.contains(user)) {
          deletedUsers.add(user);
        }
      }

      // If there are no new users, deleted users, and the group name is the same, return
      if (newUsers.isEmpty && deletedUsers.isEmpty && name == _textFieldValue) {
        users.remove(userId);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '変更がありません',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
        setState(() {
          isLoading = false; // Hide loading indicator
        });
        flag = true;
      }
      if (!flag) {
        messages.add('システム: グループ名/参加者が変更されました');
        sender.add(userId);
        time.add(Timestamp.fromDate(DateTime.now()));
        usersList = users;
        name = _textFieldValue;

        db.collection('group').doc(widget.groupId).update({
          'messages': messages,
          'sender': sender,
          'time': time,
          'users': usersList,
          'name': name,
        });
        for (var user in newUsers) {
          db.collection('userData').doc(user).get().then((doc) {
            List groups = List<String>.from(doc.data()!['group']);
            groups.add(widget.groupId);
            List lastSeen = List<int>.from(doc.data()!['groupLastSeen']);
            lastSeen.add(0);
            db.collection('userData').doc(user).update({
              'group': groups,
              'groupLastSeen': lastSeen,
            });
          });
        }
        for (var user in deletedUsers) {
          db.collection('userData').doc(user).get().then((doc) {
            List groups = List<String>.from(doc.data()!['group']);
            // get the index of the group to be removed
            final index = groups.indexOf(widget.groupId);
            groups.remove(widget.groupId);
            List lastSeen = List<int>.from(doc.data()!['groupLastSeen']);
            lastSeen.removeAt(index);
            db.collection('userData').doc(user).update({
              'group': groups,
              'groupLastSeen': lastSeen,
            });
          });
        }
        setState(() {
          isLoading = false; // Hide loading indicator
        });
        Navigator.pop(context);
      }
    });
  }

  Future leave_group() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('グループを退出しますか？'),
          content: const Text('グループから退出すると、グループのメッセージを見ることができなくなります。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true; // Show loading indicator
                });
                List messages, sender, time, usersList;
                final doc =
                    await db.collection('group').doc(widget.groupId).get();
                messages = List<String>.from(doc.data()!['messages']);
                sender = List<String>.from(doc.data()!['sender']);
                time = List<Timestamp>.from(doc.data()!['time']);
                usersList = List<String>.from(doc.data()!['users']);
                messages.add('システム: ${capitalize(userId)} がグループを退出しました');
                sender.add(userId);
                time.add(Timestamp.fromDate(DateTime.now()));
                usersList.remove(userId);
                await db.collection('group').doc(widget.groupId).update({
                  'messages': messages,
                  'sender': sender,
                  'time': time,
                  'users': usersList,
                });
                final userDoc =
                    await db.collection('userData').doc(userId).get();
                List groups = List<String>.from(userDoc.data()!['group']);
                groups.remove(widget.groupId);
                await db.collection('userData').doc(userId).update({
                  'group': groups,
                });
                if (usersList.isEmpty) {
                  await db.collection('group').doc(widget.groupId).delete();
                }
                setState(() {
                  isLoading = false; // Hide loading indicator
                });
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('退出'),
            ),
          ],
        );
      },
    );
  }

  // Capitalize the first letter of a string
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    users = List<String>.from(widget.users);
    users.remove(userId);
    _textFieldController.text = widget.name;
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    QuerySnapshot querySnapshot = await db.collection('userData').get();
    List<String> documentNames = [];
    for (var doc in querySnapshot.docs) {
      String documentName = doc.id;
      if (documentName != userId) {
        documentNames.add(capitalize(documentName));
      }
    }
    setState(() {
      suggestions = documentNames;
    });
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: const Color(0xFFF0F5FA),
        ),
        backgroundColor: const Color(0xFFF0F5FA),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: MaterialButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minWidth: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    maxLength: 20,
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      labelText: 'グループ名',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 600,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SearchField(
                    controller: _searchFieldController,
                    hint: 'ユーザー名を入力してください',
                    suggestions: isLoading
                        ? [] // Hide suggestions while loading
                        : suggestions
                            .map(SearchFieldListItem<String>.new)
                            .toList(),
                    suggestionState: Suggestion.expand,
                    maxSuggestionsInViewPort: 10,
                    suggestionsDecoration: SuggestionDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFF3E5C79),
                        width: 2,
                      ),
                    ),
                    suggestionStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    scrollbarDecoration: ScrollbarDecoration(
                      thickness: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : add_user, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF3E5C79),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator() // Show loading indicator
                      : const Text(
                          'ユーザーを追加',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '- グループ参加者 -',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Show the list of added users
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: const Color(0xFFF0F5FA),
                      child: ListTile(
                        title: Text(capitalize(users[index])),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              users.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : modify_group, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: const Color(0xFF3E5C79),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator() // Show loading indicator
                        : const Text(
                            '変更を確定',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              // Leave group chat button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: leave_group,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  child: const Text(
                    'グループを退出',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
