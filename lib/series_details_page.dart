import 'package:flutter/material.dart';
import 'database_helper.dart';

class SerialDetailPage extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final String description;
  final dynamic rating;
  final int id; // Unique identifier for the serial
  final String status; // Current status of the serial

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
  late String currentStatus; // Local copy of the status
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status; // Initialize with the passed status
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
      appBar: AppBar(title: Text(widget.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imageUrl != null)
                Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
