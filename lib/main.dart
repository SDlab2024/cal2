import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io' show Platform;

void main() {
  runApp(MyApp());
}

//ホームページ
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  void _addEvent(String event) {
    if (_selectedDay != null) {
      if (_events[_selectedDay!] == null) {
        _events[_selectedDay!] = [];
      }
      setState(() {
        _events[_selectedDay!]!.add(event);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Calendar App'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          if (_selectedDay != null) ...[
            ...(_events[_selectedDay!] ?? []).map((event) => ListTile(
              title: Text(event),
            )),
          ],
          if (Platform.isAndroid)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddEventDialog(context);
                },
                child: Text('Add Event'),
              ),
            ),
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoButton(
                color: CupertinoColors.activeBlue,
                onPressed: () {
                  _showAddEventDialog(context);
                },
                child: Text('Add Event'),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    TextEditingController _eventController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Event'),
            content: TextField(
              controller: _eventController,
              decoration: InputDecoration(labelText: 'Event'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _addEvent(_eventController.text);
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Add Event'),
            content: CupertinoTextField(
              controller: _eventController,
              placeholder: 'Event',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  _addEvent(_eventController.text);
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }
}
