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

  bool isDrawerOpen = false; // Track the state of the drawer

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final cart = ref.watch(cartProvider);
    // final mqtt = ref.watch(mqttProvider);
    final auth = ref.watch(authProvider);
    return WillPopScope(
      onWillPop: () async {
        if (isDrawerOpen) {
          context.pop();
        } else {
          // final shouldLogout = await showLogOutDialog(context);
          final shouldLogout = await customDialog(
            context: context,
            title: 'Log Out',
            message: 'Confirm logging out',
            buttons: const [
              ButtonArgs(
                text: 'Log Out',
                value: true,
              ),
              ButtonArgs(
                text: 'Cancel',
                value: false,
              ),
            ],
          );
          if (shouldLogout) {
            auth.logout();
            context.goNamed(logoRoute);
          }
        }
        return false;
      },
      child: Scaffold(
        drawer: const menu_bar.MenuBar(),
        onDrawerChanged: (isOpened) {
          isDrawerOpen = isOpened;
        },
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), //height of appbar
          child: Builder(
            builder: (BuildContext context) {
              return AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: Text(
                  'Welcome ${auth.username}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.background,
                      ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              );
            },
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
                  // var httpBody = <String, String>{
                  //   'qrcode': '123',
                  // };
                  // try {
                  //   http.Response res = await auth
                  //       .postAuthReq('/api/v1/cart/connect', body: httpBody);
                  //   devtools.log("code: ${res.statusCode}");
                  //   // if success, create cart
                  //   if (res.statusCode == 200) {
                  //     devtools.log("code: ${res.body}");
                  //     final body = jsonDecode(res.body) as Map<String, dynamic>;
                  //     cart.setID(body['id'].toString());
                  //     final mqttSuccess = await mqtt.establish(
                  //         auth.user_id, body['token'].toString());
                  //     // final mqttSuccess = true;
                  //     if (mqttSuccess) {
                  //       context.goNamed(cartRoute);
                  //     } else {
                  //       devtools.log("failed MQTT");
                  //     }
                  //   } else {
                  //     devtools.log("code: before");
                  //     // cart.setID('test');
                  //     // mqtt.establish(auth.user_id, 'test');
                  //     devtools.log("code: after");
                  //     // context.goNamed(cartRoute);
                  //   }
                  // } catch (e) {
                  //   devtools.log("$e");
                  // }
                },
                child: CustomSecondaryButton(
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
