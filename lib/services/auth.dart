import 'dart:convert';
// import 'dart:io';
import 'dart:developer' as devtools show log;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
// import '/models/user.dart';
// import '/models/user_model.dart';
import '/services/api.dart';
import '../widgets/all_widgets.dart';
// import 'env.dart' as env;
import 'package:web_socket_channel/web_socket_channel.dart';

class Auth with ChangeNotifier {
  // FirebaseAuth auth = FirebaseAuth.instance;

  /// Only changeable variable to optimize rebuild, when [_isLoggedIn] change
  ///the entire app will rebuild to control user authorization
  bool _isLoggedIn = false;
  late final WebSocketChannel channel;

  // final _secureStorage = const FlutterSecureStorage();
  // final String _loginRoute = '/api/v1/auth/login';
  final String _loginRoute = '/mobile/login';
  final String ping = '/ping';
  // final String _sendOTP = '/api/v1/tag/send_otp';
  // final String _getKeyIDRoute = '/api/v1/tag/tag';
  // final String _getRefreshToken = "/api/v1/tag/refresh_token";

  static final Auth _auth = Auth._internal();

  Auth._internal();
  factory Auth() {
    return _auth;
  }

  // Future<bool> isLoggedIn() {
  // return _secureStorage.containsKey(key: env.accessToken);
  // }
  bool isLoggedIn() {
    return _isLoggedIn;
  }

  void establishWebSocket(String url) {
    final uri = Uri.parse(url);
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen((message) {
      devtools.log("Received message: $message");
    });

    channel.sink.add("Hello, WebSocket!");
  }

  void closeSocket() {
    // channel.close();
    channel.sink.close();
    // final WebSocketChannel channel2;
    // channel = channel2;
  }
  // Future<void> checkIfLoggedIn() async {
  //   _isLoggedIn = await _secureStorage.containsKey(key: env.accessToken);
  //   _isLoggedIn = true;
  // }

  /// using [http]
  // Future<bool> login(User user, String code) async {
  Future<bool> login(BuildContext context, String email, String pass) async {
    var body = <String, String>{
      'email': email,
      'password': pass,
    };
    try {
      http.Response res = await postReq(ping, body: body);
      devtools.log("${res.statusCode}");
      devtools.log("${res.body}");
      if (res.statusCode == 200) {
        // final body = jsonDecode(res.body) as Map<String, dynamic>;
        // showAlertMassage(context, res.statusCode.toString());
        // String? authType = body[env.tokenType];
        // _setAccessToken("$authType ${body[env.accessToken]}");
        // _setRefreshToken("$authType ${body[env.refreshToken]}");
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      showAlertMassage(context, "$e");
      // throw Exception(e); // TODO: Implement internet error
      return false;
    } finally {
      // showAlertMassage(context, "$e");
    }
  }

  void logout() {
    // _secureStorage.delete(key: env.accessToken);
    _isLoggedIn = false;
    notifyListeners();
  }

//   Future<String?> getAccessToken() {
//     return _secureStorage.read(key: env.accessToken);
//   }

//   Future<String?> getRefreshToken() {
//     return _secureStorage.read(key: env.refreshToken);
//   }

//   Future<void> _setAccessToken(String token) {
//     return _secureStorage.write(key: env.accessToken, value: token);
//   }

//   Future<void> _setRefreshToken(String token) {
//     return _secureStorage.write(key: env.refreshToken, value: token);
//   }

//   String _extractAccessToken(http.Response res) {
//     final body = jsonDecode(res.body) as Map<String, dynamic>;
//     String? authType = body[env.tokenType];
//     return "$authType ${body[env.accessToken]}";
//   }

//   Future<String?> _getNewAccessToken() async {
//     http.Response res = await getReq(_getRefreshToken,
//         header: {HttpHeaders.authorizationHeader: await getRefreshToken()});
//     if (res.statusCode == 200) {
//       return _extractAccessToken(res);
//     }
//     return null;
//   }

// // To Fix the finalized request
//   http.Request _repeatRequest(http.Request req) {
  //   http.Request reReq = http.Request(req.method, req.url);
  //   reReq.body = req.body;
  //   reReq.headers.addAll(req.headers);
  //   return reReq;
  // }

  // Future<http.Response?> checkToken(http.Response res) async {
  //   if (res.statusCode == 200) {
  //     return res;
  //   } else if (res.statusCode == 401) {
  //     http.Request newReq = _repeatRequest(res.request as http.Request);
  //     if (isLoggedIn == true) {
  //       String? newAccessToken = await _getNewAccessToken();
  //       if (newAccessToken != null) {
  //         await _setAccessToken(newAccessToken);
  //         newReq.headers[HttpHeaders.authorizationHeader] = newAccessToken;
  //       }

  //       http.StreamedResponse retRes = await newReq.send();
  //       if (retRes.statusCode == 200) {
  //         return http.Response.fromStream(retRes);
  //       }
  //     }
  //   }
  //   logout();
  //   return null;
  // }

  // bool get isLoggedIn {
  //   return _isLoggedIn;
  // }

  // Future<bool> sendOTP(String masterKey) async {
  //   var body = <String, String>{
  //     'key': masterKey,
  //   };
  //   try {
  //     http.Response res = await postReq(_sendOTP, body: body);
  //     if (res.statusCode == 200) return true;
  //     return false;
  //   } catch (e) {
  //     throw Exception(e);
  //   }
  // }

}
