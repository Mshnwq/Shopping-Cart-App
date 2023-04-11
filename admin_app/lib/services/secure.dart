import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'env.dart' as env;

class SecureStorage {
  // Create an instance and enable secure encryption:
  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future setAccessToken(String token) async {
    await storage.write(key: env.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: env.accessToken);
  }

  Future setRefreshToken(String token) async {
    await storage.write(key: env.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: env.refreshToken);
  }

  Future<bool> containsData(String key) async {
    return await storage.containsKey(key: key);
  }

  void clearTokens() async {
    storage.delete(key: env.accessToken);
    storage.delete(key: env.refreshToken);
  }

  void clearAll() async {
    await storage.deleteAll();
  }
}
