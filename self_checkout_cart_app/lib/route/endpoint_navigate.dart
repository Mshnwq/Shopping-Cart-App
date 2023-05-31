import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:self_checkout_cart_app/widgets/all_widgets.dart';
import 'dart:developer' as devtools;
import 'package:http/http.dart' as http;

Future<void> EndpointAndNavigate(
  BuildContext context,
  Future<http.Response> Function() authFunction,
  void Function(BuildContext) routeFunction,
  String failMessage, {
  int? timeoutDuration,
  Future<void> Function(http.Response? result)? successCallback,
  Function()? errorCallback,
}) async {
  showLoadingDialog(context);
  bool completed = false;
  try {
    final res = await Future.any([
      authFunction(),
      Future.delayed(Duration(seconds: timeoutDuration ?? 5)).then((_) {
        if (!completed) {
          throw TimeoutException('The authentication process took too long.');
        }
      }),
    ]).then((_) {
      completed = true;
      return _!;
    });

    if (res.statusCode == 200) {
      if (successCallback != null) {
        await successCallback(res);
      }
      routeFunction(context);
    } else {
      showAlertMassage(context, failMessage);
    }
  } on TimeoutException catch (e) {
    showAlertMassage(context, e.toString());
  } on Exception catch (e) {
    try {
      String error = json
          .decode(
            e.toString().substring('Exception:'.length),
          )['detail']
          .toString();
      devtools.log(error);
      showAlertMassage(context, error);
    } on Exception catch (e2) {
      devtools.log(e2.toString());
      showAlertMassage(context, e2.toString());
    }
  } finally {
    errorCallback?.call();
    // if (errorCallback != null) {
    //   await errorCallback();
    // }
    context.pop();
  }
}
