import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
import '../widgets/all_widgets.dart';
// import '../db/db_helper.dart';
// import '../services/api.dart';
import '../services/auth.dart';
import '../services/mqtt.dart';
import 'package:http/http.dart' as http;
// import '../models/cart_model.dart';
import '../models/item_model.dart';
import '../providers/cart_provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;

// Barcode scanner imports
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qrcode_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/connectivity_service.dart';

class BarcodeScannerPage extends ConsumerWidget {
  BarcodeScannerPage({Key? key}) : super(key: key);

  ScannerController scannerController = ScannerController();

  bool _canScan = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final mqtt = ref.watch(mqttProvider);
    final completer = Completer<String>();
    // StreamSubscription subscription;

    // return StreamBuilder<String>(
    // stream: mqtt.onMessage,
    // builder: (context, snapshot) {

    return WillPopScope(
      onWillPop: () async {
        cart.setCartState("active");
        return true;
      },
      child: Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          // children: [
          //   FunctionBar(
          //     scannerController: scannerController,
          //   ),
          //   const SizedBox(
          //     height: 100,
          //   ),
          // ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              allowDuplicates: true,
              controller: scannerController.cameraController,
              onDetect: (image, args) async {
                if (!_canScan) return;
                _canScan = false;
                String? barCode = image.rawValue;
                devtools.log(barCode.toString());
                if (barCode == "" || barCode == null) {
                  return;
                } else {
                  final addToCart = await showCustomBoolDialog(
                    context,
                    "Place item on scale",
                    barCode.toString(),
                    "Add it",
                  );
                  if (addToCart) {
                    // build publish body
                    var publishBody = <String, dynamic>{
                      'mqtt_type': 'request_add_item',
                      'sender': mqtt.clientId,
                      'item_barcode': '123123',
                      // 'item_barcode': barCode.toString(),
                      'timestamp': DateTime.now().millisecondsSinceEpoch
                    };
                    try {
                      // Publish the message
                      mqtt.publish(json.encode(publishBody));

                      // Wait for the response message
                      StreamSubscription subscription;
                      devtools.log("subscribing");
                      subscription = mqtt.onMessage.listen((message) {
                        // Handle the message as desired
                        // if (message != null) {
                        completer.complete(message);
                        // }
                        // } else {
                        // }
                      });
                      // subscription.cancel();

                      devtools.log("waiting");
                      // Wait for the completer to complete
                      final mqtt_response = json.decode(await completer.future);
                      // Handle the message as desired
                      devtools.log("RESPONSE: $mqtt_response");

                      if (mqtt_response['status'] == 'success') {
                        http.Response http_res = await auth.postAuthReq(
                          '/api/v1/item/add',
                          body: <String, dynamic>{
                            'barcode': barCode.toString()
                          },
                        );
                        devtools.log("code: ${http_res.statusCode}");
                        // if success, add item to cart and exit refresh page
                        if (http_res.statusCode == 200) {
                          // if (true) {
                          Item item = mqtt_response;
                          cart.addItem(item);
                          context.goNamed(cartRoute);
                        } else {
                          devtools.log("code: HERE");
                          bool isRetry = await showCustomBoolDialog(
                            context,
                            "Server error",
                            "Please try again",
                            "retry",
                          );
                          if (isRetry) {
                            _canScan = true;
                          } else {
                            _canScan = true;
                            cart.setCartState("active");
                            GoRouter.of(context).pop();
                          }
                        }
                      } else if (mqtt_response['status'] == 'scale_fail') {
                        bool isRetry = await showCustomBoolDialog(
                            context,
                            "Failed to add item",
                            "Make sure item is placed correctly on scale",
                            "retry");
                        if (isRetry) {
                          _canScan = true;
                        } else {
                          _canScan = true;
                          cart.setCartState("active");
                          GoRouter.of(context).pop();
                        }
                      } else if (mqtt_response['status'] == 'item_not_found') {
                        showAlertMassage(context,
                            "This item is not in our database try your luck with another item");
                        cart.setCartState("active");
                        context.goNamed(cartRoute);
                      } else {
                        showAlertMassage(context, "ERROR!");
                        cart.setCartState("active");
                        context.goNamed(cartRoute);
                      }
                    } catch (e) {
                      devtools.log("$e");
                    }
                    cart.setCartState("active");
                    context.goNamed(cartRoute);
                  } else {
                    _canScan = true;
                    cart.setCartState("active");
                    GoRouter.of(context).pop();
                  }
                }
              },
            ),
            Positioned(
              top: 100,
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(85, 94, 238, 101),
                    borderRadius: BorderRadius.circular(20)),
                width: 300,
                height: 40,
                child: Center(
                  child: Text(
                    "Scan an prodcut barcode",
                    style: TextStyle(
                        // color: appTheme.textColor,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // }
    // return const CircularProgressIndicator();
    // },
    // );
  }

  void allowScan() {
    _canScan = true;
  }
}
