import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


Future<List<dynamic>> getWarnings() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.7:5000/storage/get-warnings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> warnings = data["warnings"];
      print('Warnings: ' );
      print( warnings);

      return  warnings;
    } else {
      print('Failed to get warnings');
    }
  } catch (e) {
    print('Error fetching warnings: $e');
  }
  return [];
}


