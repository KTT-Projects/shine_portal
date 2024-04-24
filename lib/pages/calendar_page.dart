// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final int year = DateTime.now().year;
  final int month = DateTime.now().month;
  final int day = DateTime.now().day;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<TimeOfDay> _selectedTime =
      List.generate(4, (index) => TimeOfDay(hour: 0, minute: 0));
  List<TimeOfDay> picked =
      List.generate(4, (index) => TimeOfDay(hour: 0, minute: 0));

  void saveNewEvent(List val) {
    FirebaseFirestore.instance.collection('training').doc().set({
      'date': _focusedDay,
      'title': _controllers[0].text,
      'timeStart': _controllers[1].text,
      'timeFinish': _controllers[2].text,
      'detail': _controllers[3].text,
    });
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    picked[index] = (await showTimePicker(
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
    String hour = picked[index].hour.toString().padLeft(2, "0");
    String min = picked[index].minute.toString().padLeft(2, "0");
    setState(() {
      _selectedTime[index] = picked[index];
      _controllers[index].text = '$hour:$min';
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.utc(year, month, day);
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
                });
              }
              if (_selectedDay != null) {
                _selectedEvents = events
                    .where((event) =>
                        event['date'] == _selectedDay!.millisecondsSinceEpoch)
                    .toList();
              }
              // _selectedEvents = events
              //     .where((event) =>
              //         event['date'] == DateTime.now().millisecondsSinceEpoch)
              //     .toList();

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
                      // setState(() {
                      //   _selectedDay = selectedDay;
                      //   _focusedDay = focusedDay;
                      // _selectedEvents = events
                      //     .where((event) =>
                      //         event['date'] ==
                      //         selectedDay.millisecondsSinceEpoch)
                      //     .toList();
                      // });
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
                      // setState(() {
                      //   _selectedDay = null;
                      //   _focusedDay = focusedDay;
                      // _selectedEvents = [];
                      // });
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
                          controller: _controllers[0],
                          decoration: InputDecoration(
                            labelText: '研修名',
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          autofocus: true,
                          controller: _controllers[1],
                          decoration: InputDecoration(
                            labelText: '開始時間',
                            isDense: true,
                          ),
                          onTap: () {
                            _selectTime(context, 1);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          autofocus: true,
                          controller: _controllers[2],
                          decoration: InputDecoration(
                            labelText: '終了時間',
                            isDense: true,
                          ),
                          onTap: () {
                            _selectTime(context, 2);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          autofocus: true,
                          controller: _controllers[3],
                          decoration: InputDecoration(
                            labelText: '内容',
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        saveNewEvent(_controllers);
                        Navigator.of(context).pop();
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
