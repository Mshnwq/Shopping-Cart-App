import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'env.dart' as env;
import 'dart:developer' as devtools show log;

class SecureStorage {
  // Create an instance and enable secure encryption:
  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future setAccessToken(String token) async {
    // devtools.log("setting access $token");
    await storage.write(key: env.accessToken, value: token);
    // devtools.log("setting access DONE!");
    // String? acstoken = await storage.read(key: env.accessToken);
    // devtools.log("Confirm $redtoken");
    // String? redtoken2 = await storage.read(key: env.accessToken);
    // devtools.log("Confirm2 $redtoken2");
  }

  Future<String?> getAccessToken() async {
    // String token = await storage.read(key: env.accessToken);
    // devtools.log("read accessToken ${token.toString()}");
    return await storage.read(key: env.accessToken);
    // return token;
  }

  Future setRefreshToken(String token) async {
    // devtools.log("setting refresh $token");
    await storage.write(key: env.refreshToken, value: token);
    // devtools.log("setting refresh DONE!");
    // String? refoken = await storage.read(key: env.refreshToken);
  }

  Future<String?> getRefreshToken() async {
    // Future<String?> token = storage.read(key: env.refreshToken);
    // devtools.log("read refresToken ${token}");
    // return storage.read(key: env.refreshToken);
    // return token;
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
