import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:self_checkout_cart_app/pages/all_pages.dart';
import '../providers/mqtt_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/routes.dart';
// import '../services/socket.dart';
import '../widgets/all_widgets.dart';
import 'dart:developer' as devtools;
import 'dart:async';

// QR code scanner imports
import '../services/qrcode_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:image_picker/image_picker.dart';

class QRScannerPage extends ConsumerWidget {
  QRScannerPage({Key? key}) : super(key: key);

  ScannerController scannerController = ScannerController();
  bool _canScan = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final mqtt = ref.watch(mqttProvider);
    const timeoutDuration = Duration(seconds: 3);

    return Scaffold(
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
              String? qrCode = image.rawValue;
              devtools.log(qrCode.toString());
              if (qrCode == "" || qrCode == null) {
                return;
              } else {
                final connectCart = await customDialog(
                  context: context,
                  title: 'Confirm QR',
                  message: 'connecting to cart ${qrCode.substring(8, 13)}',
                  buttons: [
                    const ButtonArgs(
                      text: 'Confirm',
                      value: true,
                    ),
                    const ButtonArgs(
                      text: 'Cancel',
                      value: false,
                    ),
                  ],
                );
                if (connectCart) {
                  var httpBody = <String, String>{
                    'qrcode': qrCode.toString().substring(8, 13),
                  };
                  String? errorMessage; // Variable to store the error message
                  // devtools.log("qrcode: ${qrCode.toString()}");
                  try {
                    showCustomLoadingDialog(
                      context,
                      'Connecting...',
                      'Please Wait',
                    );
                    final res = await Future.any([
                      auth.postAuthReq(
                        '/api/v1/cart/connect',
                        body: httpBody,
                      ),
                      Future.delayed(timeoutDuration).then((_) {
                        throw TimeoutException(
                            'The authentication process took too long.');
                      }),
                    ]);
                    devtools.log("res: $res");
                    // devtools.log("code: ${res[0].statusCode}");
                    // if success, create cart
                    if (res.statusCode == 200) {
                      devtools.log("code: ${res.body}");
                      final body = jsonDecode(res.body) as Map<String, dynamic>;
                      cart.setID(body['id'].toString());
                      final mqttSuccess = await mqtt.establish(
                          auth.user_id, body['token'].toString());
                      if (mqttSuccess) {
                        context.goNamed(cartRoute);
                      } else {
                        devtools.log("failed MQTT");
                      }
                    }
                  } on TimeoutException catch (e) {
                    errorMessage = e.toString();
                  } on Exception catch (e) {
                    String error = e.toString();
                    switch (error) {
                      case 'Cart-not-found':
                        devtools.log('Cart-not-found');
                        errorMessage = "User not found";
                        break;
                      case 'Cart-in-use':
                        devtools.log('Cart-in-use');
                        errorMessage = "Email not found";
                        break;
                      default:
                        devtools.log('Error: $error');
                        errorMessage = "$error";
                        break;
                    }
                  } finally {
                    context.pop();
                    if (errorMessage != null) {
                      final retryCart = await customDialog(
                        context: context,
                        title: 'Error!',
                        message: errorMessage,
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
                      if (retryCart) {
                        _canScan = true;
                      } else {
                        context.pop();
                      }
                    }
                  }
                } else {
                  _canScan = true;
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
                  "Scan a Cart QR code",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.background,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
