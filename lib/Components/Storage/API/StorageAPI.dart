 import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
 
 
 
 Future<List> fetchStorage( String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.179:5000/storage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
       

   return data['storage'];
      } else {
        print(Exception('Failed to load storage data'));
      }
    } catch (e) {
      print('Error fetching storage data: $e');
    }
    return  [];
  }