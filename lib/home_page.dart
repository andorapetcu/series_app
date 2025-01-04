import 'package:flutter/material.dart';
import 'package:series_app/series_details_page.dart';
import 'api_service.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> dbSerials = [];
  List<Map<String, dynamic>> filteredSerials = [];
  bool isLoading = true;
  String selectedStatus = 'all';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadSerials();
  }

  Future<void> loadSerials() async {
    final data = await dbHelper.fetchSerials();
    if (data.isEmpty) {
      await fetchAndSaveSerials();
    } else {
      setState(() {
        dbSerials = selectedStatus == 'all'
            ? data
            : data.where((serial) => serial['status'] == selectedStatus).toList();
        filteredSerials = dbSerials;
        isLoading = false;
      });
    }
  }

  Future<void> fetchAndSaveSerials() async {
    try {
      final data = await apiService.fetchPopularShows();
      for (var serial in data) {
        await dbHelper.insertSerial({
          'id': serial['id'],
          'name': serial['name'],
          'image': serial['image']?['medium'],
          'status': 'not watched',
        });
      }
      loadSerials();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load shows: $e')),
      );
    }
  }

  void updateStatus(int id, String status) async {
    await dbHelper.updateStatus(id, status);
    loadSerials();
  }

  void updateSelectedStatus(String status) {
    setState(() {
      selectedStatus = status;
      isLoading = true;
    });
    loadSerials();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredSerials = dbSerials.where((serial) {
        return serial['name'].toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: updateSearchQuery,
          decoration: const InputDecoration(
            hintText: "Search shows...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          DropdownButton<String>(
            value: selectedStatus,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onChanged: (value) {
              if (value != null) {
                updateSelectedStatus(value);
              }
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text("All")),
              DropdownMenuItem(value: 'watched', child: Text("Watched")),
              DropdownMenuItem(value: 'not watched', child: Text("Not Watched")),
              DropdownMenuItem(value: 'want to watch', child: Text("Want to Watch")),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: filteredSerials.length,
          itemBuilder: (context, index) {
            final serial = filteredSerials[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: serial['image'] != null
                    ? Image.network(
                  serial['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.broken_image),
                title: Text(serial['name']),
                subtitle: Text("Status: ${serial['status']}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (status) => updateStatus(serial['id'], status),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "watched", child: Text("Watched")),
                    const PopupMenuItem(value: "not watched", child: Text("Not Watched")),
                    const PopupMenuItem(value: "want to watch", child: Text("Want to Watch")),
                  ],
                ),
                onTap: () async {
                  try {
                    final details = await apiService.fetchShowDetails(serial['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SerialDetailPage(
                          name: serial['name'],
                          imageUrl: serial['image'],
                          description: details['description'],
                          rating: details['rating'],
                          id: serial['id'],
                          status: serial['status'],
                        ),
                      ),
                    ).then((_) => loadSerials()); // Reload serials after returning
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load details: $e')),
                    );
                  }
                },
              ),
            );
          }

      ),
    );
  }
}
