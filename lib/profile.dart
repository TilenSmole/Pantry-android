import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final storage = FlutterSecureStorage();
    final loadedToken = await storage.read(key: 'jwt_token');
    setState(() {
      token = loadedToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: token == null
            ?  Text(
                'Please login!',
                style: TextStyle(fontSize: 24),
              )
            : Text(
                'Token: $token',
                style: TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
