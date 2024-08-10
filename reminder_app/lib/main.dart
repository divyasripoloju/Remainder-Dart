import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

void main() {
  runApp(ReminderApp());
  tz.initializeTimeZones(); // Initialize time zones
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatefulWidget {
  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? selectedDay;
  TimeOfDay? selectedTime;
  String? selectedActivity;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep',
  ];

  @override
  void initState() {
    super.initState();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Use the correct icon path
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  Future<void> _scheduleNotification() async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Handle notifications for Windows
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Windows does not support zonedSchedule, but a reminder is set for $selectedActivity at ${selectedTime!.format(context)}'),
        ),
      );
    } else {
      // Handle notifications for other platforms
      const androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Channel for reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('reminder_sound'), // Use file name without extension
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      final now = DateTime.now();
      final scheduledTime = tz.TZDateTime.from(
        DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute),
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        'Time for $selectedActivity',
        scheduledTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define custom text style
    TextStyle headingStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Day',
                      style: headingStyle,
                    ),
                    DropdownButton<String>(
                      value: selectedDay,
                      hint: Text('Choose a day'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDay = newValue;
                        });
                      },
                      items: days.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Time',
                        style: headingStyle,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Choose Time'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'No time selected',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Activity',
                      style: headingStyle,
                    ),
                    DropdownButton<String>(
                      value: selectedActivity,
                      hint: Text('Choose an activity'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedActivity = newValue;
                        });
                      },
                      items: activities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDay != null &&
                      selectedTime != null &&
                      selectedActivity != null) {
                    _scheduleNotification();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select day, time, and activity'),
                      ),
                    );
                  }
                },
                child: Text('Set Reminder'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
