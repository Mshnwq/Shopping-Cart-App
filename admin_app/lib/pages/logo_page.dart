import 'package:admin_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../widgets/all_widgets.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools show log;
import 'package:http/http.dart' as http;

class LogoPage extends ConsumerWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    final auth = ref.watch(authProvider);
    return Scaffold(
      // endDrawer: const MenuBar(),
      appBar: AppBar(
          // backgroundColor: appTheme.green,
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  http.Response res = await auth
                      .postReq('/api/v1/cart/update_status/${auth.cart_id}/0');
                  devtools.log("code: ${res.statusCode}");
                } catch (e) {
                  devtools.log("$e");
                }
              },
              // style: appTheme.getButtonStyle,
              child: Text(
                'Set Cart Ready',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var httpBody = <String, String>{
                  'qrcode': auth.cart_id,
                };
                try {
                  http.Response res = await auth
                      .postAuthReq('/api/v1/cart/connect', body: httpBody);
                  devtools.log("code: ${res.statusCode}");
                } catch (e) {
                  devtools.log("$e");
                }
              },
              // style: appTheme.getButtonStyle,
              child: Text(
                'Raise Alarm',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  http.Response res = await auth
                      .postReq('/api/v1/cart/update_status/${auth.cart_id}/1');
                  devtools.log("code: ${res.statusCode}");
                } catch (e) {
                  devtools.log("$e");
                }
              },
              // style: appTheme.getButtonStyle,
              child: Text(
                'Close Alarm',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            InkWell(
              onLongPress: () async {
                var httpBody = <String, String>{
                  'qrcode': auth.cart_id,
                  'barcode': '1231231',
                  'process_id': '100001',
                };
                try {
                  http.Response res = await auth
                      .postReq('/api/v1/item/admin_add', body: httpBody);
                  devtools.log("code: ${res.statusCode}");
                } catch (e) {
                  devtools.log("$e");
                }
              },
              child: ElevatedButton(
                // style: appTheme.getButtonStyle,
                onPressed: () {
                  context.pushNamed(
                    barcodeRoute,
                    extra: {
                      'action': 'add',
                    },
                  );
                },
                child: Text(
                  'Add Item',
                  // style: appTheme.getButtonTextStyle,
                ),
              ),
            ),
            InkWell(
              onLongPress: () async {
                var httpBody = <String, String>{
                  'qrcode': auth.cart_id,
                  'barcode': '1231231',
                  'process_id': '100001',
                };
                try {
                  http.Response res = await auth
                      .postReq('/api/v1/item/admin_remove', body: httpBody);
                  devtools.log("code: ${res.statusCode}");
                  devtools.log("code: ${res.body}");
                } catch (e) {
                  devtools.log("$e");
                }
              },
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed(
                    barcodeRoute,
                    extra: {
                      'action': 'remove',
                    },
                  );
                },
                // style: appTheme.getButtonStyle,
                child: Text(
                  'Remove Item',
                  // style: appTheme.getButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
