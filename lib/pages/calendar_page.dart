// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  // final events = {
  //   DateTime.utc(2024, 3, 8): ['first', 'second'],
  //   DateTime.utc(2024, 3, 9): ['third', 'forth'],
  // };
  Map events = {
    DateTime.utc(2024, 3, 8): [
      {
        'title': 'First',
        'start': '13:00',
        'end': '13:30',
        'detail':
            '昔マーフィーはこのモットーが言いました、「すべては原因、結果の法則によります。運命論者のいう運・不運は、貴方の思考や行動と無縁ではない。」短いながら、この言葉は私に様々な考えを持たせます。 この方面から考えるなら、昔ソローは不意にこう言いました、「すべての不幸は未来への踏み台にすぎない。」それによって私は啓発されました、 個人的に言うなら、消費税100%増税は私にとって非常に重要だと言わなければならないです。 昔カーリル・ギブランは不意にこう言いました、「お互いに手をつなぐ時にも間をあけよう。」こうした中、私の疑問が解けました。昔ジミー・コーナーズはこう言いました、「１試合にわたって集中力を維持するためには、適度にリラックスすることが絶対に必要だと思う。」諸君にもこの言葉の意味をちゃんと味わわせようと思います。 しかしながら、こんなことでも、消費税100%増税の現れにはある意味意義を持っていると考えられる。 私にとって、 昔河合隼雄はこのモットーが言いました、「あくる朝起きたら、また違う風が吹いているからね。」短いながら、この言葉は私に様々な考えを持たせます。 消費税100%増税と言いますと、消費税100%増税をどう書くのが要となる。 この方面から考えるなら、こうであれば。\n消費税100%増税はなんのことで発生したのか？昔ソローはこう言ったことがある、「すべての不幸は未来への踏み台にすぎない。」諸君にもこの言葉の意味をちゃんと味わわせようと思います。 消費税100%増税は一体どんな存在なのかをきっちりわかるのが全ての問題の解くキーとなります。 消費税100%増税を発生するには、一体どうやってできるのか。一方、消費税100%増税を発生させない場合、何を通じてそれをできるのでしょうか。 消費税100%増税は一体どんな存在なのかをきっちりわかるのが全ての問題の解くキーとなります。 昔北畠親房は不意にこう言いました、「あめつちの初めは今日より始まる。」思い返せば。 昔尾崎士郎は不意にこう言いました、「あれもいい、これもいいという生き方はどこにもねえや。あっちがよけりゃこっちが悪いに決まっているのだから、これだと思ったときに盲滅法に進まなけりゃ嘘だよ。」こうした中、私の疑問が解けました。しかしながら、こんなことでも、消費税100%増税の現れにはある意味意義を持っていると考えられる。',
        'pdf': '本当はPDFだよ',
      },
      {
        'title': 'Second',
        'start': '9:00',
        'end': '10:00',
        'detail':
            '例：私本人もじっくり考えながら、夜となく昼となく予定１のことを考えています。 しかし、こうした件は全部が重要ではない。もっと重要なのは。',
        'pdf': '本当はPDFだよ',
      },
    ],
    DateTime.utc(2024, 3, 9): [
      {
        'title': 'Third',
        'start': '12:40',
        'end': '14:35',
        'detail':
            '例：私本人もじっくり考えながら、夜となく昼となく予定１のことを考えています。 しかし、こうした件は全部が重要ではない。もっと重要なのは。',
        'pdf': '本当はPDFだよ',
      },
      {
        'title': 'Forth',
        'start': '16:45',
        'end': '18:00',
        'detail':
            '例：私本人もじっくり考えながら、夜となく昼となく予定１のことを考えています。 しかし、こうした件は全部が重要ではない。もっと重要なのは。',
        'pdf': '本当はPDFだよ',
      },
    ],
  };
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Map<String, Object>> _selectedEvents = [];
  final List<TimeOfDay> _selectedTime = List.generate(4, (index) => TimeOfDay(hour: 0, minute: 0));
  List<TimeOfDay> picked = List.generate(4, (index) => TimeOfDay(hour: 0, minute: 0));

  void saveNewEvent(String value) {
    print(value);
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
  }

  @override
  Widget build(BuildContext context) {
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
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedEvents = events[selectedDay] ?? [];
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
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
              daysOfWeekHeight: 30,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(.5),
                  // color: Color(0xFF3E5C79),
                  shape: BoxShape.circle,
                ),
                todayTextStyle:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              eventLoader: (day) {
                return events[day] ?? [];
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${event['title']}'),
                                  Text(
                                    '${event['start']}~${event['end']}',
                                    style: const TextStyle(fontSize: 16.0),
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
        ),
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
                        saveNewEvent(_controllers[0].text);
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
