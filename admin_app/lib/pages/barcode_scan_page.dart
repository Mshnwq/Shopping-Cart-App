import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/all_widgets.dart';
import '../providers/auth_provider.dart';

import 'package:http/http.dart' as http;
import '../constants/routes.dart';
import '../services/env.dart' as env;
import 'dart:developer' as devtools;

// Barcode scanner imports
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qrcode_scanner.dart';

class BarcodeScannerPage extends ConsumerWidget {
  final String action;
  final String index;
  final String barcodeToRead;

  BarcodeScannerPage({
    Key? key,
    required this.action,
    required this.index,
    required this.barcodeToRead,
  }) : super(key: key);

  ScannerController scannerController = ScannerController();
  bool _canScan = true;
  bool _awaitHttp = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    devtools.log("action $action");
    devtools.log("toBarcode $barcodeToRead");
    devtools.log("index $index");

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // MobileScanner(
          //   allowDuplicates: true,
          //   controller: scannerController.cameraController,
          //   onDetect: (image, args) async {
          //     if (!_canScan) return;
          //     _canScan = false;
          //     String? barCode = image.rawValue;
          //     devtools.log(barCode.toString());
          //     if (barCode == "" || barCode == null) {
          //       return;
          //     } else {
          //       bool isValidBarcode;
          //       if (action == 'add') {
          //         isValidBarcode = true;
          //       } else {
          //         isValidBarcode = barcodeToRead == barCode;
          //       }
          //       if (isValidBarcode) {
          //         final addToCart = await showCustomBoolDialog(
          //           context,
          //           "Place item on scale",
          //           barCode.toString(),
          //           "Add it",
          //         );
          //         if (addToCart) {
          //           var timestamp = DateTime.now().millisecondsSinceEpoch;
          //           // build publish body

          //             // Publish the message
          //             // Wait for the response message
          //             devtools.log("subscribing");
          //             // StreamSubscription subscription =
          //                 // mqtt.onItemMessage.listen((message) {
          //               // completer.complete(message);
          //               // _awaitMqtt = false;
          //               // devtools.log("waiting done");
          //             // });
          //             devtools.log("waiting");
          //             // Wait for the completer to complete
          //             final mqttResponse =
          //                 json.decode(await completer.future);
          //             // Handle the message as desired
          //             // subscription.cancel();
          //             devtools.log("waiting done");
          //             _awaitMqtt = false;
          //             // devtools.log("RESPONSE: $mqttResponse");
          //             if (mqttResponse['status'] == 'success') {
          //               // devtools.log("HERE_11");
          //               http.Response httpRes = await auth.postAuthReq(
          //                 '/api/v1/item/$action',
          //                 body: <String, String>{
          //                   // 'barcode': barCode.toString(),
          //                   'barcode': '1231231',
          //                   'process_id': timestamp.toString(),
          //                 },
          //               );
          //               //   '/api/v1/item/get_image',
          //               // http.Response ☻imageRes = await auth.postAuthReq(
          //               //   body: <String, dynamic>{
          //               //     'barcode': barCode.toString(),
          //               //   },
          //               // );
          //               devtools.log("code: ${httpRes.statusCode}");
          //               // if success, add item to cart and exit refresh page
          //               if (httpRes.statusCode == 200) {
          //                 // if (true) {
          //                 if (action == 'add') {
          //                   var product = json.decode(httpRes.body);
          //                   devtools.log("$product");
          //                   // var blob = json.decode(imageRes.body)['img_link'];
          //                   // Uint8List productImage;
          //                   // if (blob != null) {
          //                   // Only decode if blob is not null to prevent crashes
          //                   // productImage = base64.decode(blob);
          //                   // } else {
          //                   // TODO Empty
          //                   // productImage = base64.decode(blob);
          //                 }
          //                 context.goNamed(cartRoute);
          //               }
          //             } else if (mqttResponse['status'] == 'scale_fail') {
          //               bool isRetry = await showCustomBoolDialog(
          //                   context,
          //                   "Failed to $action item",
          //                   "Make sure item is placed correctly on scale",
          //                   "Retry");
          //               if (isRetry) {
          //                 _canScan = true;
          //               } else {
          //                 GoRouter.of(context).pop();
          //               }
          //             } else if (mqttResponse['status'] == 'acce_fail') {
          //               bool isRetry = await showCustomBoolDialog(
          //                   context,
          //                   "Failed to $action item",
          //                   "Make sure cart is not moving",
          //                   "Retry");
          //               if (isRetry) {
          //                 _canScan = true;
          //               } else {
          //                 GoRouter.of(context).pop();
          //               }
          //             } else if (mqttResponse['status'] == 'item_not_found') {
          //               devtools.log("HERE_4");
          //               bool isRetry = await showCustomBoolDialog(
          //                 context,
          //                 "Item Not Found",
          //                 "This item is not in our database try your luck with another item",
          //                 "Ok",
          //               );
          //               if (isRetry) {
          //                 context.goNamed(cartRoute);
          //               } else {
          //                 context.goNamed(cartRoute);
          //               }
          //             } else {
          //               bool isRetry = await showCustomBoolDialog(
          //                 context,
          //                 "ERROR",
          //                 "Unexpexted error has occured",
          //                 "Ok",
          //               );
          //               if (isRetry) {
          //                 context.goNamed(cartRoute);
          //               } else {
          //                 context.goNamed(cartRoute);
          //               }
          //             }
          //           } catch (e) {
          //             devtools.log("$e");
          //             bool isRetry = await showCustomBoolDialog(
          //               context,
          //               "Server error",
          //               "$e",
          //               "Retry",
          //             );
          //             if (isRetry) {
          //               _canScan = true;
          //             } else {
          //               GoRouter.of(context).pop();
          //             }
          //           }
          //         } else {
          //           GoRouter.of(context).pop();
          //         }
          //       } else {
          //         bool isRetry = await showCustomBoolDialog(
          //             context,
          //             "Wrong barcode",
          //             "Make sure you are scanning the same item you chose",
          //             "Retry");
          //         if (isRetry) {
          //           _canScan = true;
          //         } else {
          //           GoRouter.of(context).pop();
          //         }
          //       }
          //     }
          //   },
          // ),
          Positioned(
            top: 100,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(85, 94, 238, 101),
                  borderRadius: BorderRadius.circular(20)),
              width: 300,
              height: 40,
              child: const Center(
                child: Text(
                  "Scan an prodcut barcode",
                  style: TextStyle(),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _awaitHttp,
            child: Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
