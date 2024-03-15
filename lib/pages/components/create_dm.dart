import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

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

  Future create_dm() async {
    bool flag = false;
    _searchFieldValue = _searchFieldController.text;
    if (_searchFieldValue == '') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ユーザー名を入力してください',
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
      return;
    }
    CollectionReference userData = db.collection('userData');
    final docRef = userData.doc(userId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['room_id'].forEach((value) {
        if (value == _searchFieldValue.toLowerCase()) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'このユーザーとのDMはすでに存在します',
                textAlign: TextAlign.center,
              ),
              backgroundColor: const Color(0xFFFF6B6B),
            ),
          );
          flag = true;
        }
      });
      if (flag) {
        return;
      }
      suggestions.forEach((value) {
        if (value.toLowerCase() == _searchFieldValue.toLowerCase()) {
          flag = true;
        }
      });
      if (!flag) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ユーザーが見つかりませんでした',
              textAlign: TextAlign.center,
            ),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
        return;
      }
      data['room_id'].add(_searchFieldValue.toLowerCase());
      docRef.update(data);
    } else {
      AlertDialog(
        title: const Text('エラー'),
        content: const Text('ユーザーが見つかりませんでした'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    }
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
    querySnapshot.docs.forEach((doc) {
      String documentName = doc.id;
      if (documentName != userId) {
        documentNames.add(capitalize(documentName));
      }
    });
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
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: MaterialButton(
                onPressed: () {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SearchField(
              controller: _searchFieldController,
              hint: 'Basic SearchField',
              suggestions:
                  suggestions.map(SearchFieldListItem<String>.new).toList(),
              suggestionState: Suggestion.expand,
              maxSuggestionsInViewPort: 10,
              suggestionsDecoration: SuggestionDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              scrollbarDecoration: ScrollbarDecoration(
                thickness: 0,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: create_dm,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              backgroundColor: const Color(0xFF3E5C79),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            ),
            child: const Text(
              'DMを作成',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
