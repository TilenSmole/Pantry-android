import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  var isLogedIn = false;

  Future<void> login(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.179:5000/login'),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}),
      );
      print(response.statusCode);
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);

        final String token = responseJson['token'];

        await prefs.setString('token', token);


        // Save the token using flutter_secure_storage
        await storage.write(key: 'jwt_token', value: token);
        print('Token saved successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePage()), // Adjust this to navigate to your desired home page
        );
            } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
          child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your email',
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your password',
            ),
          ),
          ElevatedButton(
            child: Text("LOGIN"),
            onPressed: () {
              final email = _emailController.text;
              final password = _passwordController.text;
              login(email, password);
            },
          ),
        ],
      )),
    );
  }
}
