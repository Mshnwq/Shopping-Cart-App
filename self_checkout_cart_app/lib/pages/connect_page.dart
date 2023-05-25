import 'dart:convert';

import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/menu_bar.dart' as menu_bar;
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import '../providers/mqtt_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;
import 'package:http/http.dart' as http;

class ConnectPage extends ConsumerWidget {
  ConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final mqtt = ref.watch(mqttProvider);
    final auth = ref.watch(authProvider);
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showLogOutDialog(context);
        if (shouldLogout) {
          auth.logout();
          context.goNamed(logoRoute);
        }
        return false;
      },
      child: Scaffold(
        drawer: const menu_bar.MenuBar(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), //height of appbar
          child: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Welcome ${auth.username}',
              style: Theme.of(context).textTheme.titleLarge,
              // style: appTheme.setButtonTextStyle(22, 1.5),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onLongPress: () async {
                  // TODO remove shortcut
                  var httpBody = <String, String>{
                    'qrcode': '123',
                  };
                  // if success, add item to cart and exit refresh page
                  try {
                    http.Response res = await auth
                        .postAuthReq('/api/v1/cart/connect', body: httpBody);
                    devtools.log("code: ${res.statusCode}");
                    // if success, create cart
                    if (res.statusCode == 200) {
                      devtools.log("code: ${res.body}");
                      final body = jsonDecode(res.body) as Map<String, dynamic>;
                      cart.setID(body['id'].toString());
                      final mqttSuccess = await mqtt.establish(
                          auth.user_id, body['token'].toString());
                      // final mqttSuccess = true;
                      if (mqttSuccess) {
                        context.goNamed(cartRoute);
                      } else {
                        devtools.log("failed MQTT");
                      }
                    } else {
                      devtools.log("code: before");
                      cart.setID('test');
                      // mqtt.establish(auth.user_id, 'test');
                      devtools.log("code: after");
                      context.goNamed(cartRoute);
                    }
                  } catch (e) {
                    devtools.log("$e");
                  }
                },
                child: ConnectButton(
                  onPressed: () => context.goNamed(qrScanRoute),
                  text: 'Scan QR code',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
