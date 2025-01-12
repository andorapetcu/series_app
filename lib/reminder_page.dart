import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderPage extends StatefulWidget {
  final int id;
  final String name;

  const ReminderPage({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().initialize(
      'resource://drawable/series_icon',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for reminders',
          defaultColor: Colors.lightGreen[600],
          ledColor: Colors.white,
          icon: 'resource://drawable/ic_notification',
        ),
      ],
    );
    requestNotificationPermission();
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted");
    } else {
      print("Notification permission denied");
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void scheduleReminder() async {
    PermissionStatus notificationPermissionStatus = await Permission.notification.status;
    if (notificationPermissionStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are not on')),
      );
      return;
    }

    if (selectedDate != null && selectedTime != null) {
      final DateTime scheduledDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      if (scheduledDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose a date that is in the future!')),
        );
        return;
      }

      print('Scheduled DateTime: $scheduledDateTime');

      Future.delayed(Duration(seconds: 2), () {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: widget.id,
            channelKey: 'basic_channel',
            title: 'Reminder: ${widget.name}',
            body: 'Don\'t forget to watch ${widget.name}!',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar.fromDate(date: scheduledDateTime),
        ).then((_) {
          print("Scheduled notification for ${widget.name} was created!");
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder scheduled successfully!')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Set Reminder'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => selectDate(context),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.green[100],
                  child: ListTile(
                    title: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMd().format(selectedDate!),
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Icon(Icons.calendar_today, color: Colors.lightGreenAccent[600]),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => selectTime(context),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.green[100],
                  child: ListTile(
                    title: Text(
                      selectedTime == null
                          ? 'Select Time'
                          : selectedTime!.format(context),
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Icon(Icons.access_time, color: Colors.lightGreenAccent[600]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: scheduleReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen[600],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Set Reminder',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
