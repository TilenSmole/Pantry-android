import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> addNote(String note, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/notes/add-note'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'note': note,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
            List<dynamic> notesList = data["notes"];

      List<Map<String, dynamic>> typedNotesList =
          List<Map<String, dynamic>>.from(notesList);

      return typedNotesList;
    } else {
      throw Exception('Failed to load recipes');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
   return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}

Future<List<dynamic>?> deleteNote(int noteId, String token) async {
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.179:5000/notes/delete-note'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'noteId': noteId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return data["notes"];
    } else {
      throw Exception('Failed to load recipes');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
}

Future<List<Map<String, dynamic>>> editNote(
    String newNote, int noteId, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/notes/edit-note'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'newNote': newNote, 'noteId': noteId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
   List<dynamic> notesList = data["notes"];

      List<Map<String, dynamic>> typedNotesList =
          List<Map<String, dynamic>>.from(notesList);

      return typedNotesList;
    } else {
      throw Exception('Failed to load recipes');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}

Future<List<Map<String, dynamic>>> getNotes(String? token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/notes/'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data["notes"]);
      List<dynamic> notesList = data["notes"];
      List<Map<String, dynamic>> typedNotesList =
          List<Map<String, dynamic>>.from(notesList);

      return typedNotesList;
    }else if(response.statusCode == 404){



    }
    
     else {
      print('Failed to upload to a shopping list from a recipe');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}
