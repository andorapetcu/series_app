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
          defaultColor: Color(0xFF9D50DD),
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
        const SnackBar(content: Text('Notificările sunt dezactivate în setările dispozitivului.')),
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
          const SnackBar(content: Text('Data și ora selectată trebuie să fie în viitor!')),
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

      // AwesomeNotifications().createNotification(
      //   content: NotificationContent(
      //     id: 10,
      //     channelKey: 'basic_channel',
      //     title: 'Reminder',
      //     body: 'Este timpul să îți amintești de acest lucru!',
      //   ),
      // ).then((_) {
      //   print("Immediate notification was sent!");
      // });

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
      appBar: AppBar(title: const Text('Set Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : DateFormat.yMd().format(selectedDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => selectDate(context),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(selectedTime == null
                  ? 'Select Time'
                  : selectedTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => selectTime(context),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: scheduleReminder,
              child: const Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
