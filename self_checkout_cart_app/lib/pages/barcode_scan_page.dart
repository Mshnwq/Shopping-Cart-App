import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/all_widgets.dart';
import '../providers/mqtt_provider.dart';
import '../providers/auth_provider.dart';

import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../providers/cart_provider.dart';
import '../constants/routes.dart';
import '../services/env.dart' as env;
import 'dart:developer' as devtools;

// Barcode scanner imports
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qrcode_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/connectivity_service.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final mqtt = ref.watch(mqttProvider);
    final scale_completer = Completer<String>();
    final item_completer = Completer<String>();

    devtools.log("action $action");
    devtools.log("toBarcode $barcodeToRead");
    devtools.log("index $index");

    return WillPopScope(
      onWillPop: () async {
        cart.setCartState("active");
        return true;
      },
      child: Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
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
                  bool isValidBarcode;
                  if (action == 'add') {
                    isValidBarcode = true;
                  } else {
                    isValidBarcode = barcodeToRead == barCode;
                  }
                  if (isValidBarcode) {
                    final addToCart = await showCustomBoolDialog(
                      context,
                      "Place item on scale",
                      barCode.toString(),
                      "Add it",
                    );
                    if (addToCart) {
                      var timestamp = DateTime.now().millisecondsSinceEpoch;
                      // build publish body
                      var publishBody = <String, String>{
                        'mqtt_type': 'request_${action}_item',
                        'sender': mqtt.clientId,
                        // 'item_barcode': '123',
                        'item_barcode': barCode.toString(),
                        'timestamp': timestamp.toString()
                      };
                      try {
                        // Publish the request
                        mqtt.publish(json.encode(publishBody));
                        // Wait for the scale response message
                        devtools.log("subscribing scale");
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        StreamSubscription scaleSubscription =
                            mqtt.onScaleMessage.listen((message) {
                          scale_completer.complete(message);
                          devtools.log("scale waiting done");
                        });
                        StreamSubscription itemSubscription =
                            mqtt.onItemMessage.listen((message) {
                          item_completer.complete(message);
                          devtools.log("item waiting done");
                        });

                        bool completed = false;
                        final mqttResponseScale = await Future.any([
                          scale_completer.future,
                          item_completer.future,
                          Future.delayed(
                            const Duration(seconds: 5),
                          ).then((_) {
                            if (!completed) {
                              throw TimeoutException(
                                  'The process took too long.');
                            }
                          }),
                        ]).then((response) {
                          completed = true;
                          return json.decode(response!);
                        });
                        // Wait for the scale completer to complete

                        // Handle the message as desired
                        scaleSubscription.cancel();
                        itemSubscription.cancel();
                        context.pop();
                        devtools.log("scale completed done");
                        // devtools.log("RESPONSE: $mqttResponse");
                        if (mqttResponseScale['status'] == 'item_not_found') {
                          // context.pop();
                          final isRetry = await customDialog(
                            context: context,
                            title: 'Item not Found!',
                            message:
                                "This item is not in our database try your luck with another item",
                            buttons: const [
                              ButtonArgs(
                                text: 'Retry',
                                value: true,
                              ),
                              ButtonArgs(
                                text: 'Cancel',
                                value: false,
                              ),
                            ],
                          );
                          if (isRetry) {
                            _canScan = true;
                          }
                          cart.setCartState("active");
                          context.goNamed(cartRoute);
                        }
                        if (mqttResponseScale['status'] == 'pass') {
                          // Wait for the penet completer to complete
                          showCustomLoadingDialog(
                            context,
                            "Scale Success!",
                            "Move the item with one hand to storage",
                          );
                          StreamSubscription subscription =
                              mqtt.onItemMessage.listen((message) {
                            item_completer.complete(message);
                            devtools.log("item waiting done");
                          });
                          bool completed = false;
                          final mqttResponsePenet = await Future.any([
                            item_completer.future,
                            Future.delayed(
                              const Duration(seconds: 15),
                            ).then((_) {
                              if (!completed) {
                                throw TimeoutException(
                                    'The process took too long.');
                              }
                            }),
                          ]).then((response) {
                            completed = true;
                            return json.decode(response!);
                          });
                          // Handle the message as desired
                          subscription.cancel();
                          context.pop();
                          devtools.log("item completed done");
                          // on penetration success
                          if (mqttResponsePenet['status'] == 'success') {
                            // devtools.log("HERE_11");
                            http.Response httpRes = await auth.postAuthReq(
                              '/api/v1/item/$action',
                              body: <String, String>{
                                'barcode': barCode.toString(),
                                // 'barcode': '123',
                                'process_id': timestamp.toString(),
                              },
                            );

                            devtools.log("code: ${httpRes.statusCode}");
                            // if success, add item to cart and exit refresh page
                            if (httpRes.statusCode == 200) {
                              if (action == 'add') {
                                var product = json.decode(httpRes.body);
                                devtools.log("$product");
                                Item item = Item(
                                    barcode: barCode.toString(),
                                    name: product['en_name'],
                                    unit: 'Kg',
                                    price: product['price'],
                                    count: 1,
                                    image:
                                        "http://${env.baseURL}${product['img_path']}");
                                cart.addItem(item);
                              } else {
                                // if case is remove
                                cart.removeItem(
                                    cart.getItems()[int.parse(index)]);
                              }
                              cart.setCartState("active");
                              context.goNamed(cartRoute);
                            }
                          } else {
                            bool isRetry = await showCustomBoolDialog(
                                context,
                                "Failed to $action item",
                                "Make sure item is not leaving the cart",
                                "Retry");
                            if (isRetry) {
                              _canScan = true;
                            } else {
                              cart.setCartState("active");
                              GoRouter.of(context).pop();
                            }
                          }
                        } else if (mqttResponseScale['status'] ==
                            'scale_fail') {
                          bool isRetry = await showCustomBoolDialog(
                              context,
                              "Failed to $action item",
                              "Make sure item is placed correctly on scale",
                              "Retry");
                          if (isRetry) {
                            _canScan = true;
                          } else {
                            cart.setCartState("active");
                            GoRouter.of(context).pop();
                          }
                        } else if (mqttResponseScale['status'] == 'acce_fail') {
                          bool isRetry = await showCustomBoolDialog(
                              context,
                              "Failed to $action item",
                              "Make sure cart is not moving",
                              "Retry");
                          if (isRetry) {
                            _canScan = true;
                          } else {
                            cart.setCartState("active");
                            GoRouter.of(context).pop();
                          }
                        } else if (mqttResponseScale['status'] ==
                            'item_not_found') {
                          // devtools.log("HERE_4");
                          bool isRetry = await showCustomBoolDialog(
                            context,
                            "Item Not Found",
                            "This item is not in our database try your luck with another item",
                            "Ok",
                          );
                          if (isRetry) {
                            cart.setCartState("active");
                            context.goNamed(cartRoute);
                          } else {
                            cart.setCartState("active");
                            context.goNamed(cartRoute);
                          }
                        } else {
                          bool isRetry = await showCustomBoolDialog(
                            context,
                            "ERROR",
                            "Unexpexted error has occured",
                            "Ok",
                          );
                          if (isRetry) {
                            cart.setCartState("active");
                            context.goNamed(cartRoute);
                          } else {
                            cart.setCartState("active");
                            context.goNamed(cartRoute);
                          }
                        }
                      } on TimeoutException catch (e) {
                        bool isRetry = await showCustomBoolDialog(
                          context,
                          "Time out",
                          "$e",
                          "Retry",
                        );
                        if (isRetry) {
                          cart.setCartState("active");
                          GoRouter.of(context).pop();
                        } else {
                          cart.setCartState("active");
                          GoRouter.of(context).pop();
                        }
                      } on Exception catch (e) {
                        devtools.log("$e");
                        bool isRetry = await showCustomBoolDialog(
                          context,
                          "Server error",
                          "$e",
                          "Retry",
                        );
                        if (isRetry) {
                          _canScan = true;
                        } else {
                          cart.setCartState("active");
                          GoRouter.of(context).pop();
                        }
                      }
                    } else {
                      cart.setCartState("active");
                      GoRouter.of(context).pop();
                    }
                  } else {
                    bool isRetry = await showCustomBoolDialog(
                        context,
                        "Wrong barcode",
                        "Make sure you are scanning the same item you chose",
                        "Retry");
                    if (isRetry) {
                      _canScan = true;
                    } else {
                      cart.setCartState("active");
                      GoRouter.of(context).pop();
                    }
                  }
                }
              },
            ),
            Positioned(
              top: 100,
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0x552ECC71),
                    borderRadius: BorderRadius.circular(20)),
                width: 300,
                height: 40,
                child: Center(
                  child: Text(
                    "Scan a product barcode",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.background,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
