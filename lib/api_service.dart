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
}
