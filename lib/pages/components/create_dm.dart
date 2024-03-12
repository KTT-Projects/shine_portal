import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Future create_dm() async {
    String userId =
        FirebaseAuth.instance.currentUser!.email!.replaceAll('@shine.com', '');
    _searchFieldValue = _searchFieldController.text;
    final docRef = db.collection('userData').doc(_searchFieldValue);
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);
        if (data == null) {
          print('No such document!');
        } else {
          print('Document data: ${doc.data()}');
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
    // Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              suggestions: ['ABC', 'DEF', 'GHI', 'JKL']
                  .map(SearchFieldListItem<String>.new)
                  .toList(),
              suggestionState: Suggestion.expand,
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
