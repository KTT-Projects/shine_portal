import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:searchfield/searchfield.dart';

class CreateDm extends StatefulWidget {
  const CreateDm({super.key});

  @override
  State<CreateDm> createState() => _CreateDmState();
}

class _CreateDmState extends State<CreateDm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // width: 600,
      // height: 10000,
      backgroundColor: const Color(0xFFF0F5FA),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding:
                  const EdgeInsets.all(10), // Add padding for all directions
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Make the corners round
                ),
                minWidth: 0,
                child: const Padding(
                  padding: EdgeInsets.all(
                      5), // Add padding for all directions inside the button
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    4), // Adjust the border radius value as desired
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
