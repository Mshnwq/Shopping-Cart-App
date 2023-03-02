import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devtools show log;
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '/services/api.dart';
import '../widgets/all_widgets.dart';
import 'env.dart' as env;
import 'package:web_socket_channel/web_socket_channel.dart';

class Auth with ChangeNotifier {
  // FirebaseAuth auth = FirebaseAuth.instance;

  /// Only changeable variable to optimize rebuild, when [_isLoggedIn] change
  ///the entire app will rebuild to control user authorization
  bool _isLoggedIn = false;
  late final WebSocketChannel channel;

  final _secureStorage = const FlutterSecureStorage();
  final String _loginRoute = '/api/v1/mobile/login';
  final String _registerRoute = '/api/v1/mobile/register';
  final String _getRefreshToken = "/api/v1/mobile/refresh_token";
  final String ping = '/ping';

  static final Auth _auth = Auth._internal();

  Auth._internal();
  factory Auth() {
    return _auth;
  }

  void establishWebSocket() {
    final uri = Uri.parse(env.sock);
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen((message) {
      devtools.log("Received message: $message");
    });

    channel.sink.add("Hello, WebSocket!");
  }

  void closeSocket() {
    try {
      channel.sink.close();
    } catch (e) {
      return;
    }
  }

  Future<bool> login(BuildContext context, String email, String pass) async {
    var body = <String, String>{
      'username': email,
      'password': pass,
    };
    try {
      http.Response res = await loginReq(_loginRoute, body: body);
      devtools.log("${res.statusCode}");
      devtools.log("${res.body}");
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        // showAlertMassage(context, res.statusCode.toString());
        String? authType = body[env.tokenType];
        _setAccessToken("$authType ${body[env.accessToken]}");
        _setRefreshToken("$authType ${body[env.refreshToken]}");
        // _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      showAlertMassage(context, "$e");
      throw Exception(e); // TODO: Implement internet error
      // return false;
      // } finally {
      // showAlertMassage(context, "$e");
    }
  }

  /// using [http]
  Future<bool> register(
      BuildContext context, String username, String email, String pass) async {
    var body = <String, String>{
      'username': username,
      "full_name": "string",
      'email': email,
      "role": '0',
      "phone_num": "966501386297",
      'hashed_password': pass,
      "birthdate": "2000-03-02"
    };
    try {
      http.Response res = await postReq(_registerRoute, body: body);
      devtools.log("${res.statusCode}");
      devtools.log("${res.body}");
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        // showAlertMassage(context, res.statusCode.toString());
        String? authType = body[env.tokenType];
        _setAccessToken("$authType ${body[env.accessToken]}");
        _setRefreshToken("$authType ${body[env.refreshToken]}");
        // _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      showAlertMassage(context, "$e");
      throw Exception(e); // TODO: Implement internet error
      // return false;
      // } finally {
      // showAlertMassage(context, "$e");
    }
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: env.accessToken);
  }

  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: env.refreshToken);
  }

  Future<void> _setAccessToken(String token) {
    return _secureStorage.write(key: env.accessToken, value: token);
  }

  Future<void> _setRefreshToken(String token) {
    return _secureStorage.write(key: env.refreshToken, value: token);
  }

  String _extractAccessToken(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    String? authType = body[env.tokenType];
    return "$authType ${body[env.accessToken]}";
  }

  Future<String?> _getNewAccessToken() async {
    http.Response res = await getReq(_getRefreshToken,
        header: {HttpHeaders.authorizationHeader: await getRefreshToken()});
    if (res.statusCode == 200) {
      return _extractAccessToken(res);
    }
    return null;
  }

  http.Request _repeatRequest(http.Request req) {
    http.Request reReq = http.Request(req.method, req.url);
    reReq.body = req.body;
    reReq.headers.addAll(req.headers);
    return reReq;
  }

  Future<http.Response?> checkToken(http.Response res) async {
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      http.Request newReq = _repeatRequest(res.request as http.Request);
      if (isLoggedIn) {
        String? newAccessToken = await _getNewAccessToken();
        if (newAccessToken != null) {
          await _setAccessToken(newAccessToken);
          newReq.headers[HttpHeaders.authorizationHeader] = newAccessToken;
        }

        http.StreamedResponse retRes = await newReq.send();
        if (retRes.statusCode == 200) {
          return http.Response.fromStream(retRes);
        }
      }
    }
    logout();
    return null;
  }

  // Future<bool> isLoggedIn() {
  //   return _isLoggedIn;
  // }

  bool get isLoggedIn {
    return _isLoggedIn;
  }

  Future<void> checkIfLoggedIn() async {
    _isLoggedIn = await _secureStorage.containsKey(key: env.accessToken);
  }

  void logout() {
    _secureStorage.delete(key: env.accessToken);
    _isLoggedIn = false;
    closeSocket();
    notifyListeners();
  }
}
