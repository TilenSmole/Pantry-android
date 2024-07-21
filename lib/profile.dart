import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Text(
          'This is a profile page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
