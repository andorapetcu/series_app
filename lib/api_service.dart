import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';

  Future<List<dynamic>> fetchPopularShows() async {
    final response = await http.get(Uri.parse('$baseUrl/shows'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load shows');
    }
  }

  Future<Map<String, dynamic>> fetchShowDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'description': data['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'No description available',
        'rating': data['rating']?['average'] ?? 'No rating available',
      };
    } else {
      throw Exception('Failed to load show details');
    }
  }


}
