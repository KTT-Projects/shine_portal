// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:async';
import 'dart:core';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<TimeOfDay> _selectedTime =
      List.generate(4, (index) => TimeOfDay(hour: 0, minute: 0));
  final FocusNode _focus = FocusNode();
  final storage = FirebaseStorage.instance;
  File? _file;

  void saveNewEvent(List val) {
    FirebaseFirestore.instance.collection('training').doc().set({
      'date': _focusedDay,
      'title': _controllers[0].text,
      'timeStart': _controllers[1].text,
      'timeFinish': _controllers[2].text,
      'detail': _controllers[3].text,
      'pdf': '',
    });
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    _selectedTime[index] = (await showTimePicker(
      context: context,
      initialTime: _selectedTime[index],
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    ))!;
    _controllers[index].text = _selectedTime[index].format(context);
    String hour = _selectedTime[index].hour.toString().padLeft(2, "0");
    String min = _selectedTime[index].minute.toString().padLeft(2, "0");
    setState(() {
      _selectedTime[index] = _selectedTime[index];
      _controllers[index].text = '$hour:$min';
    });
  }

  Future getPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      _file = File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    super.initState();
    // getInfo();
    // _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    print(_focus);
    if (_focus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
      _focus.unfocus();
    }
  }

  final db = FirebaseFirestore.instance;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: db.collection('training').snapshots(),
            builder: (context, snapshot) {
              List events = [], _selectedEvents = [];
              events.clear();
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final documents = snapshot.data!.docs;
              for (var index = 0; index < documents.length; index++) {
                events.add({
                  'date':
                      documents[index]['date'].toDate().millisecondsSinceEpoch,
                  'title': documents[index]['title'],
                  'start': documents[index]['timeStart'],
                  'end': documents[index]['timeFinish'],
                  'detail': documents[index]['detail'],
                  'pdf': documents[index]['pdf'],
                });
              }
              if (_selectedDay != null) {
                _selectedEvents = events
                    .where((event) =>
                        event['date'] == _selectedDay!.millisecondsSinceEpoch)
                    .toList();
              }
              return Column(
                children: [
                  TableCalendar(
                    locale: 'ja_JP',
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      if (format == CalendarFormat.week) {
                        format = CalendarFormat.month;
                      }
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _selectedDay = null;
                        _focusedDay = focusedDay;
                        _selectedEvents = [];
                      });
                      print(events);
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      leftChevronPadding: const EdgeInsets.all(0),
                      rightChevronPadding: const EdgeInsets.all(0),
                      leftChevronIcon: Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.keyboard_double_arrow_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                    daysOfWeekHeight: 30,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(.5),
                        // color: Color(0xFF3E5C79),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    eventLoader: (day) {
                      return events
                          .where((event) =>
                              event['date'] == day.millisecondsSinceEpoch)
                          .toList();
                    },
                  ),
                  // MaterialButton(
                  //   color: Theme.of(context).colorScheme.secondary,
                  //   textColor: Theme.of(context).colorScheme.onSecondary,
                  //   onPressed: () {
                  //     setState(() {
                  //       _focusedDay = DateTime.now();
                  //     });
                  //   },
                  //   child: const Text('今月に戻る'),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _selectedEvents[index];
                        return Card(
                          child: ListTile(
                            title: Text('${event['title']}'),
                            subtitle: Text('${event['start']}~${event['end']}'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    title: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${event['title']}'),
                                        Text(
                                          '${event['start']}~${event['end']}',
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                    // content: Column(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   children: [
                                    //     Text('${event['detail']}'),
                                    //     // PDFView(),
                                    //   ],
                                    // ),
                                    content: Scrollbar(
                                      child: SingleChildScrollView(
                                        child: Text('${event['detail']}'),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('閉じる'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '新規研修予定の追加',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          controller: _controllers[0],
                          decoration:
                              InputDecoration(labelText: '研修名', isDense: true),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          controller: _controllers[1],
                          // focusNode: _focus,
                          decoration:
                              InputDecoration(labelText: '開始時間', isDense: true),
                          onTap: () {
                            _selectTime(context, 1);
                            // _focus.addListener(_onFocusChange);
                            // FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          controller: _controllers[2],
                          focusNode: _focus,
                          decoration:
                              InputDecoration(labelText: '終了時間', isDense: true),
                          onTap: () {
                            _selectTime(context, 2);
                            // _focus.addListener(_onFocusChange);
                            // FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          controller: _controllers[3],
                          decoration:
                              InputDecoration(labelText: '内容', isDense: true),
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        getPdfFile();
                      },
                      child: const Text('PDFを追加'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        saveNewEvent(_controllers);
                        Navigator.of(context).pop();
                        print(_file);
                      },
                      child: const Text('追加'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
}



// Map<String, int> data = {};
// var formattedDate;
// var utcDate;
// var year_date;
// var month_date;
// var day_date;
// var date;

// var int_year;
// var int_month;
// var int_day;

// Future<void> getSchedule() async {
//   final collectionRef = FirebaseFirestore.instance.collection('training'); // CollectionReference
//   final querySnapshot = await collectionRef.get(); // QuerySnapshot
//   final queryDocSnapshot = querySnapshot.docs; // List<QueryDocumentSnapshot>

//   for (final snapshot in queryDocSnapshot) {
//     final data = await snapshot.data(); // `data()` で中身を非同期に取得
//     // データ処理を行う

//     final date = (data['date'] as Timestamp).toDate().millisecondsSinceEpoch;

//     // final dateField = data['date'];

//     // if (dateField is Timestamp) {
//     //   final dateTime = dateField.toDate();
//     //   year_date = dateTime.year.toInt();
//     //   month_date = dateTime.month.toInt();
//     //   day_date = dateTime.day.toInt();
//     //   formattedDate = "$year_date, $month_date, $day_date";
//     //   print("フォーマット済み日付: $formattedDate");
//     // } else {
//     //   print("Invalid date format: $dateField");
//     // }
//     // final dateComponents = formattedDate.split(', ');
//     // int_year = int.parse(dateComponents[0]);
//     // int_month = int.parse(dateComponents[1]);
//     // int_day = int.parse(dateComponents[2]);
//     // print(int_year);
//     // print(int_month);
//     // print(int_day);
//   }
// }

// void getInfo() async {
//   await getSchedule();
// }


