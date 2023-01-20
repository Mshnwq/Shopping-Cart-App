// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'dart:io';
// import '/services/auth.dart';
import 'package:http/http.dart' as http;
import 'env.dart' as env;
import 'dart:developer' as devtools show log;

// String _getCarriagesRoute = "/api/v1/tag/bags";
// String _postReportMissingBag = "/api/v1/bag/missing";
Future<http.Response> postReq(String route,
    {Map<String, dynamic>? body, Map<String, dynamic>? header}) {
  // return http.post(Uri.http(env.baseUrl, route),
  devtools.log(env.url);
  devtools.log(route);
  // devtools.log(header.toString());
  final uri = Uri.http(env.url, route);
  devtools.log(uri.toString());
  return http.post(uri, body: jsonEncode(body), headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    ...?header
  });
}

Future<http.Response> getReq(String route, {Map<String, dynamic>? header}) {
  return http.get(Uri.http(env.baseUrl, route), headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    ...?header
  });
}

Future<http.Response> sendEmptyPost(String route,
    {Map<String, dynamic>? body, Map<String, dynamic>? header}) async {
  // devtools.log(route);
  // devtools.log(header.toString());
  // devtools.log(env.url);
  // return http.post(
  //   Uri.http(env.url, route),
  // body: {},
  // headers: <String, String>{
  // 'Content-Type': 'application/json; charset=UTF-8',
  // ...?header
  // },
  // );
  final uri = Uri.http(env.url, route);
  final headers = {
    'Content-Type': 'application/json',
    "Accept": "application/json",
  };
  Map<String, dynamic> body = {'id': 21, 'name': 'bob'};
  String jsonBody = json.encode(body);
  final encoding = Encoding.getByName('utf-8');
  devtools.log(env.url);
  devtools.log(route);
  devtools.log(header.toString());
  devtools.log(uri.toString());
  http.Response response = await http.post(
    uri,
    headers: headers,
    body: jsonBody,
    // body: body,
    encoding: encoding,
  );
  devtools.log(response.body);
  return response;
}

// Future<http.Response?> postAuthReq(String route,
//     {Map<String, dynamic>? body, Map<String, dynamic>? header}) async {
//   Map<String, dynamic> authHeader = {
//     "Authorization": await Auth().getAccessToken(),
//     ...?header
//   };
//   http.Response res = await postReq(route, body: body, header: authHeader);
//   http.Response? checkedRes = await Auth().checkToken(res);
//   return checkedRes;
// }

// Future<http.Response?> getAuthReq(String route,
//     {Map<String, dynamic>? header}) async {
//   Map<String, String> authHeader = {
//     HttpHeaders.authorizationHeader: await Auth().getAccessToken() ?? "",
//     ...?header
//   };
//   try {
//     http.Response res = await getReq(route, header: authHeader);
//     http.Response? checkedRes = await Auth().checkToken(res);
//     return checkedRes;
//   } catch (e) {
//     throw Exception(e);
//   }
// }

// Future<void> getAllBags(BuildContext context) async {
//   http.Response? res = await getAuthReq(_getCarriagesRoute);
//   if (res == null) return;
//   if (res.statusCode == 200) {
//     List<dynamic> body = List<Map<String, dynamic>>.from(jsonDecode(res.body));
//     CarriageList().sinkList(body
//         .map<Carriage>((carriage) => Carriage.fromJson(carriage, context))
//         .toList());
//   }
// }

// Future<void> reportMissingBag(String id, String? message) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String masterKey = prefs.getString(env.masterKey)!;
//   await postAuthReq(_postReportMissingBag,
//       body: {"tag_id": masterKey + id, "message": message, "status": 0});
// }
