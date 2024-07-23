import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> loadToken() async {
  final storage = FlutterSecureStorage();
  final loadedToken = await storage.read(key: 'jwt_token');
  return loadedToken;
}
