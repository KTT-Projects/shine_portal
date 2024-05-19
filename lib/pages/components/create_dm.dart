import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shine_portal/pages/chat_room.dart';

class CreateDm extends StatefulWidget {
  const CreateDm({Key? key}) : super(key: key);

  @override
  State<CreateDm> createState() => _CreateDmState();
}

class _CreateDmState extends State<CreateDm> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchFieldController = TextEditingController();
  String _searchFieldValue = '';
  final db = FirebaseFirestore.instance;
  String userId =
      FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');
  int chatIndex = 0;

  bool isLoading = false; // Added loading state

  Future create_dm() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    String dmId_ = '';
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
    CollectionReference userData = db.collection('userData');
    final docRef = userData.doc(userId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['dm']?.forEach((value) {
        if (value == _searchFieldValue.toLowerCase()) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'このユーザーとのDMはすでに存在します',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
          flag = true;
        }
      });
      if (flag) {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
        return;
      }
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
      CollectionReference dm = db.collection('dm');
      final newDocRef = await dm.add({
        'messages': ['システム: DMが作成されました'],
        'time': [DateTime.now()],
        'sender': [userId],
      });
      final newDocId = newDocRef.id;
      data['dm'].add(_searchFieldValue.toLowerCase());
      data['dmId'].add(newDocId);
      data['dmLastSeen'].add(0);
      docRef.update(data);
      final docRef2 = userData.doc(_searchFieldValue.toLowerCase());
      final docSnapshot2 = await docRef2.get();
      if (docSnapshot2.exists) {
        final data2 = docSnapshot2.data() as Map<String, dynamic>;
        if (data2['dm'] == null) {
          data2['dm'] = [];
          data2['dmId'] = [];
        }
        data2['dm'].add(userId);
        data2['dmId'].add(newDocId);
        data2['dmLastSeen'].add(0);
        docRef2.update(data2);
      }
      chatIndex = data['dm'].length - 1;
      dmId_ = newDocId;
    }
    setState(() {
      isLoading = false; // Hide loading indicator
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualChatRoom(
          name: capitalize(_searchFieldValue.toLowerCase()),
          dmId: dmId_,
          chatIndex: chatIndex,
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
              height: 50,
            ),
            Container(
              width: 600,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : create_dm, // Disable button when loading
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
                          'DMを作成',
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
