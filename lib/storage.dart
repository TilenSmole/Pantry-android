import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Components/load_token.dart' as load_token;
import 'dart:convert';

class Storage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateStorageState();
}

class CreateStorageState extends State<Storage> {
  List _storage = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) {
      fetchStorage();
    });
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();
    setState(() {
      token = loadedToken;
    });
  }

  Future<void> fetchStorage() async {
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
        setState(() {
          _storage = data["storage"];
        });
      } else {
        print( Exception('Failed to load storage data'));
      }
    } catch (e) {
      print('Error fetching storage data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage Page'),
      ),
      body: Center(
        child: _storage.isEmpty
            ? Text('No items in storage')
            : ListView.builder(
                itemCount: _storage.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_storage[index].toString()),
                  );
                },
              ),
      ),
    );
  }
}
