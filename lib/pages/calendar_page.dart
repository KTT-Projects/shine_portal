import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pdfx/pdfx.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  final int year = DateTime.now().year;
  final int month = DateTime.now().month;
  final int day = DateTime.now().day;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<TimeOfDay> _selectedTime =
      List.generate(4, (index) => TimeOfDay(hour: 0, minute: 0));
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
    String hour = _selectedTime[index].hour.toString().padLeft(2, '0');
    String min = _selectedTime[index].minute.toString().padLeft(2, '0');
    setState(() {
      _selectedTime[index] = _selectedTime[index];
      _controllers[index].text = '$hour:$min';
    });
  }

  Uint8List? _pdf;
  String? _pdfName;
  Future getPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      _pdf = result.files.single.bytes;
      if (result.files.single.name.split('.')[1] != 'pdf') {
        setState(() => _pdfName = '${result.files.single.name}.pdf');
      } else {
        setState(() => _pdfName = result.files.single.name);
      }
    } else {
      _pdf = null;
      setState(() => _pdfName = null);
    }
  }

  bool checkInput() {
    for (var index = 0; index < _controllers.length; index++) {
      if (_controllers[index].text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future saveNewEvent() async {
    FirebaseFirestore.instance.collection('training').add({
      'date': _selectedDay,
      'title': _controllers[0].text,
      'timeStart': _controllers[1].text,
      'timeFinish': _controllers[2].text,
      'detail': _controllers[3].text,
      'pdf': _pdfName,
    }).then((value) async {
      await FirebaseStorage.instance
          .ref()
          .child('training/${value.id}/$_pdfName')
          .putData(_pdf!);
      _pdf = null;
      _pdfName = null;
    });
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = '';
    }
  }

  var _pdfController = null;
  Uint8List? _pdfBytes;
  String? _docId;
  Future<Uint8List> getPdf(String docId, String fileName) async {
    final data = await FirebaseStorage.instance
        .ref()
        .child('training/$docId/$fileName')
        .getData();
    _docId = docId;
    return data as Uint8List;
  }

  void downloadPDF(String fileName) async {
    final params = SaveFileDialogParams(data: _pdfBytes, fileName: fileName);
    await FlutterFileDialog.saveFile(params: params);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.utc(year, month, day);
  }

  final FocusNode _focus = FocusNode();
  void _onFocusChange() {
    if (_focus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
      _focus.unfocus();
    }
  }

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('training').snapshots(),
      builder: (context, snapshot) {
        List events = [], selectedEvents = [];
        events.clear();
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final documents = snapshot.data!.docs;
        for (var i = 0; i < documents.length; i++) {
          events.add({
            'id': documents[i].id,
            'date': documents[i]['date'].toDate().millisecondsSinceEpoch,
            'title': documents[i]['title'],
            'start': documents[i]['timeStart'],
            'end': documents[i]['timeFinish'],
            'detail': documents[i]['detail'],
            'pdf': documents[i]['pdf'],
          });
        }
        // sort events based on timeStart
        if (_selectedDay != null) {
          selectedEvents = events
              .where((event) =>
                  event['date'] == _selectedDay!.millisecondsSinceEpoch)
              .toList();
          selectedEvents.sort((a, b) {
            var aTime = a['start'].split(':');
            var bTime = b['start'].split(':');
            return int.parse(aTime[0]) * 60 +
                int.parse(aTime[1]) -
                (int.parse(bTime[0]) * 60 + int.parse(bTime[1]));
          });
        }
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TableCalendar(
                  locale: 'ja_JP',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) => setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  }),
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
                      selectedEvents = [];
                    });
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
                  eventLoader: (day) => events
                      .where((event) =>
                          event['date'] == day.millisecondsSinceEpoch)
                      .toList(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return Card(
                        child: ListTile(
                          title: Text('${event['title']}'),
                          subtitle: Text('${event['start']}~${event['end']}'),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                                builder: (context, setState) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      title: Column(
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
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Scrollbar(
                                              child: SingleChildScrollView(
                                                  child: Text(
                                                      '${event['detail']}')),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Builder(
                                            builder: (context) {
                                              if (!kIsWeb) {
                                                if (_pdfBytes == null ||
                                                    _docId != event['id']) {
                                                  getPdf(event['id'],
                                                          event['pdf'])
                                                      .then((value) =>
                                                          setState(() {
                                                            _pdfBytes = value;
                                                          }));
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else {
                                                  _pdfController =
                                                      PdfControllerPinch(
                                                          document: PdfDocument
                                                              .openData(
                                                                  _pdfBytes!));
                                                  return MaterialButton(
                                                    child: Text(
                                                        '${event['pdf']} を見る'),
                                                    onPressed: () {
                                                      _pdfController =
                                                          PdfControllerPinch(
                                                              document: PdfDocument
                                                                  .openData(
                                                                      _pdfBytes!));
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Scaffold(
                                                            body: Container(
                                                              color:
                                                                  Colors.white,
                                                              child: Stack(
                                                                children: [
                                                                  PdfViewPinch(
                                                                      controller:
                                                                          _pdfController),
                                                                  Positioned(
                                                                    left: 20,
                                                                    bottom: 30,
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        minimumSize: const Size(
                                                                            50,
                                                                            50),
                                                                        shape:
                                                                            const CircleBorder(),
                                                                      ),
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      child: const Icon(
                                                                          Icons
                                                                              .arrow_back),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    right: 20,
                                                                    bottom: 30,
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        minimumSize: const Size(
                                                                            50,
                                                                            50),
                                                                        shape:
                                                                            const CircleBorder(),
                                                                      ),
                                                                      onPressed:
                                                                          () =>
                                                                              downloadPDF(event['pdf']),
                                                                      child: const Icon(
                                                                          Icons
                                                                              .download),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                return Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      RichText(
                                                          text: const TextSpan(
                                                              text:
                                                                  '現在使用しているプラットフォームはPDFビュアーが使用できません')),
                                                      RichText(
                                                          text: TextSpan(
                                                              children: [
                                                            const TextSpan(
                                                                text:
                                                                    'こちらクリックしてダウンロードしてください：  '),
                                                            TextSpan(
                                                              text:
                                                                  event['pdf'],
                                                              recognizer:
                                                                  TapGestureRecognizer()
                                                                    ..onTap =
                                                                        () async {
                                                                      String url = await FirebaseStorage
                                                                          .instance
                                                                          .ref()
                                                                          .child(
                                                                              'training/${event['id']}/${event['pdf']}')
                                                                          .getDownloadURL();
                                                                      launchUrl(
                                                                          Uri.parse(
                                                                              url));
                                                                    },
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                              ),
                                                            ),
                                                          ])),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('閉じる'),
                                        ),
                                      ],
                                    )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0)),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              if (_selectedDay != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '新規研修予定の追加',
                              style: TextStyle(
                                fontSize: 18.0,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
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
                                  decoration: const InputDecoration(
                                      labelText: '研修名', isDense: true),
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
                                  decoration: const InputDecoration(
                                      labelText: '開始時間', isDense: true),
                                  onTap: () => _selectTime(context, 1),
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
                                  decoration: const InputDecoration(
                                      labelText: '終了時間', isDense: true),
                                  onTap: () => _selectTime(context, 2),
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
                                  decoration: const InputDecoration(
                                      labelText: '内容', isDense: true),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: MaterialButton(
                                onPressed: () async {
                                  await getPdfFile();
                                  setState(() {});
                                },
                                child: Text(_pdfName ?? 'PDFファイルを選択'),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                if (checkInput() && _pdf != null) {
                                  saveNewEvent();
                                  Navigator.of(context).pop();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Center(child: Text('エラー')),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(child: Text('以下の項目を確認してください')),
                                          Text('・項目がすべて埋まっているか'),
                                          Text('・時間が正しく入力されているか'),
                                          Text('・PDFファイルが選択されているか'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('閉じる'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: const Text('追加'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                setState(() {});
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('エラー'),
                    content: const Text('日付を選択してください'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('閉じる'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        );
      },
    );
  }
}
