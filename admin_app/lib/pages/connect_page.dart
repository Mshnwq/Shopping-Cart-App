import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;
import 'package:http/http.dart' as http;

class ConnectPage extends ConsumerWidget {
  ConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), //height of appbar
        child: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          // backgroundColor: appTheme.green,
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
                  'qrcode': 'Welcome',
                };
                // if success, add item to cart and exit refresh page
                try {
                  http.Response res = await auth
                      .postAuthReq('/api/v1/cart/connect', body: httpBody);
                  devtools.log("code: ${res.statusCode}");
                  // if success, create cart
                  if (res.statusCode == 200) {
                    devtools.log("code: ${res.body}");
                    context.goNamed(cartRoute);
                  }
                } catch (e) {
                  devtools.log("$e");
                }
              },
              child: ElevatedButton(
                onPressed: () => context.goNamed(qrScanRoute),
                child: const Text('Scan QR code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
