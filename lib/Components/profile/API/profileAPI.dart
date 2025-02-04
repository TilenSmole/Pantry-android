import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> addNote(String note, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/notes/add-note'),
      headers: {
        'Authorization': 'Bearer $token',
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
        'Authorization': 'Bearer $token',
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
  return null;
}

Future<List<Map<String, dynamic>>> editNote(
    String newNote, int noteId, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/notes/edit-note'),
      headers: {
        'Authorization': 'Bearer $token',
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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey("notes") && data["notes"] is List) {
        List<dynamic> notesList = data["notes"];
        List<Map<String, dynamic>> typedNotesList =
            List<Map<String, dynamic>>.from(
                notesList.map((note) => Map<String, dynamic>.from(note)));

        return typedNotesList;
      }
    } else if (response.statusCode == 404) {
    } else {
      print('Failed to');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}

Future<List<Map<String, dynamic>>> getNotesLocal(String? token) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notes = prefs.getString('notes');
    if (notes != null) {
      try {
        print(notes);
        final decodedData = jsonDecode(notes);
        if (decodedData is List<dynamic>) {
          return decodedData
              .map((note) => note as Map<String, dynamic>)
              .toList();
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}

Future<void> addNotesLocal(String note, String token) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notes = prefs.getString('notes');
    String? idItemStr = prefs.getString('idItem');
    int idItem = idItemStr != null ? int.parse(idItemStr) : 0;

    if (notes != null) {
      try {
        final decodedData = jsonDecode(notes);
        decodedData.map((note) => note as Map<String, dynamic>).toList();
        decodedData.add({"id": idItem - 1, "note": note, "userId": 1});
        await prefs.setString('notes', jsonEncode(decodedData));
        await prefs.setString('idItem', (idItem - 1).toString());
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    }
  } catch (e) {
    print('Error accessing SharedPreferences: $e');
  }
}

Future<void> deleteNoteLocal(int noteId, String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? notes = prefs.getString('notes');
  if (notes != null) {
    List<Map<String, dynamic>>  temp = []; 
    try {
      final decodedData = jsonDecode(notes);
      decodedData.forEach((note) {
          if(!(note['id'] == noteId)){
            temp.add(note);
          }
      });
      await prefs.setString('notes', jsonEncode(temp));

    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }
}


Future<void> editNoteLocal(String newNote, int noteId, String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? notes = prefs.getString('notes');
  if (notes != null) {
    List<Map<String, dynamic>>  temp = []; 
    try {
      final decodedData = jsonDecode(notes);
      decodedData.forEach((note) {
          if((note['id'] == noteId)){
            note['note'] =  newNote;
            temp.add(note);
          }
          else{
           temp.add(note);
          }
      });
      await prefs.setString('notes', jsonEncode(temp));

    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }
}
