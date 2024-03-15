import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shine_portal/pages/chat_room_tmp.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
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

  Future create_group() async {
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

    CollectionReference userData = db.collection('userData');
    final docRef = userData.doc(userId);
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>;
    if (data['group'] == null) {
      data['group'] = [];
    }
    CollectionReference group = db.collection('group');
    final newDocRef = await group.add({
      'messages': 'グループが作成されました',
      'time': DateTime.now(),
      'users': users,
      'sender': userId,
      'name': _textFieldValue,
    });
    final newDocId = newDocRef.id;
    data['group'].add(newDocId);
    docRef.update(data);
    // Add the group to each user's data
    CollectionReference userData2 = db.collection('userData');
    for (var user in users) {
      final docRef2 = userData2.doc(user);
      final docSnapshot2 = await docRef2.get();
      final data2 = docSnapshot2.data() as Map<String, dynamic>;
      if (data2['group'] == null) {
        data2['group'] = [];
      }
      data2['group'].add(newDocId);
      docRef2.update(data2);
    }
    setState(() {
      isLoading = false; // Hide loading indicator
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatRoom(
          name: _textFieldValue,
        ),
      ),
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
    return Scaffold(
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
                  controller: _textFieldController,
                  decoration: InputDecoration(
                    hintText: 'グループ名を入力してください',
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
                onPressed:
                    isLoading ? null : add_user, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: const Color(0xFF3E5C79),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                child: isLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text(
                        'ユーザーを追加',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              '- 追加ユーザーの一覧 -',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // Show the list of added users
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Color(0xFFF0F5FA),
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
            SizedBox(
              height: 40,
            ),
            Container(
              width: 600,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : create_group, // Disable button when loading
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
                          'グループを作成',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
