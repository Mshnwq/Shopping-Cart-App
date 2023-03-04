import 'dart:convert';
import 'dart:io';
import '/services/auth.dart';
import 'package:http/http.dart' as http;
import 'env.dart' as env;
import 'dart:developer' as devtools show log;

Future<http.Response> loginReq(String route,
    {Map<String, dynamic>? body, Map<String, dynamic>? header}) {
  final uri = Uri.http(env.url, route);
  return http.post(
    uri,
    body: body,
  );
}

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
  return http.get(Uri.http(env.url, route), headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    ...?header
  });
}

Future<http.Response> sendEmptyPost(String route,
    {Map<String, dynamic>? body, Map<String, dynamic>? header}) async {
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

Future<http.Response> postAuthReq(String route,
    {Map<String, dynamic>? body, Map<String, dynamic>? header}) async {
  Map<String, dynamic> authHeader = {
    "Authorization": await Auth().getAccessToken(),
    ...?header
  };
  devtools.log(env.url);
  devtools.log(route);
  devtools.log(header.toString());
  // devtools.log(uri.toString());
  http.Response res = await postReq(route, body: body, header: authHeader);
  // http.Response checkedRes = await Auth().checkToken(res);
  // return checkedRes;
  return res;
}

Future<http.Response?> getAuthReq(String route,
    {Map<String, dynamic>? header}) async {
  Map<String, String> authHeader = {
    HttpHeaders.authorizationHeader: await Auth().getAccessToken() ?? "",
    ...?header
  };
  try {
    http.Response res = await getReq(route, header: authHeader);
    http.Response? checkedRes = await Auth().checkToken(res);
    return checkedRes;
  } catch (e) {
    throw Exception(e);
  }
}
