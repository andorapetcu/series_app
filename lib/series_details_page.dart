import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'reminder_page.dart';

class SerialDetailPage extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final String description;
  final dynamic rating;
  final int id;
  final String status;

  const SerialDetailPage({
    Key? key,
    required this.name,
    required this.description,
    required this.id,
    required this.status,
    this.imageUrl,
    this.rating,
  }) : super(key: key);

  @override
  _SerialDetailPageState createState() => _SerialDetailPageState();
}

class _SerialDetailPageState extends State<SerialDetailPage> {
  late String currentStatus;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
  }

  Future<void> updateStatus(String status) async {
    await dbHelper.updateStatus(widget.id, status);
    setState(() {
      currentStatus = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to "$status"!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[50],
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.lightGreen[900]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.imageUrl != null)
                    Container(
                      width: double.infinity,
                      height: constraints.maxWidth > 600
                          ? 300
                          : 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightGreen[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.rating != null)
                    Text(
                      "Rating: ${widget.rating.toString()}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Current Status: $currentStatus",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: currentStatus,
                    onChanged: (value) {
                      if (value != null) {
                        updateStatus(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: "watched", child: Text("Watched")),
                      DropdownMenuItem(value: "not watched", child: Text("Not Watched")),
                      DropdownMenuItem(value: "want to watch", child: Text("Want to Watch")),
                    ],
                    dropdownColor: Colors.lightGreen[400],
                    style: TextStyle(color: Colors.lightGreen[900]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReminderPage(
                            id: widget.id,
                            name: widget.name,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen[600],
                    ),
                    child: Text(
                      'Set Reminder to Watch Later',
                      style: TextStyle(color: Colors.lightGreen[50]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
