// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '/services/auth.dart';
// import 'package:http/http.dart' as http;
// import 'env.dart' as env;
// import 'dart:developer' as devtools show log;

// final apiProvider = ChangeNotifierProvider((ref) => API());

// class API with ChangeNotifier {
//   // Auth _auth = Auth();

//   Future<http.Response> loginReq(String route,
//       {Map<String, dynamic>? body, Map<String, dynamic>? header}) {
//     final uri = Uri.http(env.baseURL, route);
//     return http.post(
//       uri,
//       body: body,
//     );
//   }

//   Future<http.Response> postReq(String route,
//       {Map<String, dynamic>? body, Map<String, dynamic>? header}) {
//     devtools.log('POST PATH');
//     devtools.log(env.baseURL);
//     devtools.log(route);
//     return http.post(
//       Uri.http(env.baseURL, route),
//       body: jsonEncode(body),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         ...?header
//       },
//     );
//   }

//   Future<http.Response> getReq(String route, {Map<String, dynamic>? header}) {
//     devtools.log('GET PATH');
//     devtools.log(env.baseURL);
//     devtools.log(route);
//     return http.get(
//       Uri.http(env.baseURL, route),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         ...?header
//       },
//     );
//   }

//   Future<http.Response> sendEmptyPost(
//     String route,
//   ) async {
//     final uri = Uri.http(env.baseURL, route);
//     final headers = {
//       'Content-Type': 'application/json',
//       "Accept": "application/json",
//     };
//     Map<String, dynamic> body = {'id': 21, 'name': 'bob'};
//     String jsonBody = json.encode(body);
//     final encoding = Encoding.getByName('utf-8');
//     devtools.log(env.baseURL);
//     devtools.log(route);
//     devtools.log(headers.toString());
//     devtools.log(uri.toString());
//     http.Response response = await http.post(
//       uri,
//       headers: headers,
//       body: jsonBody,
//       // body: body,
//       encoding: encoding,
//     );
//     devtools.log(response.body);
//     return response;
//   }

//   Future<http.Response> postAuthReq(String route,
//       {Map<String, dynamic>? body, Map<String, dynamic>? header}) async {
//     devtools.log("Hello5,!");
//     Map<String, dynamic> authHeader = {
//       "Authorization": await _auth.secureStorage.getAccessToken(),
//       ...?header
//     };
//     devtools.log("Hello11,!");
//     devtools.log(header.toString());
//     try {
//       http.Response res = await postReq(route, body: body, header: authHeader);
//       devtools.log("Hello1,!");
//       http.Response checkedRes = await _auth.checkToken(res);
//       devtools.log("Hello3,!");
//       return checkedRes;
//     } catch (e) {
//       throw Exception(e);
//     }
//   }

//   Future<http.Response> getAuthReq(String route,
//       {Map<String, dynamic>? header}) async {
//     Map<String, String> authHeader = {
//       HttpHeaders.authorizationHeader:
//           await _auth.secureStorage.getAccessToken() ?? "",
//       ...?header
//     };
//     try {
//       http.Response res = await getReq(route, header: authHeader);
//       devtools.log("Hello1,!");
//       http.Response checkedRes = await _auth.checkToken(res);
//       devtools.log("Hello2,!");
//       return checkedRes;
//     } catch (e) {
//       throw Exception(e);
//     }
//   }
// }
