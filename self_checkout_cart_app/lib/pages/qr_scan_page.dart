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
                  // message: 'connecting to cart ${qrCode.substring(8, 13)}',
                  message: 'connecting to cart $qrCode',
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
                    // 'qrcode': qrCode.toString().substring(8, 13),
                    'qrcode': '123',
                  };
                  String? errorMessage; // Variable to store the error message
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
                      Future.delayed(const Duration(seconds: 6)).then((_) {
                        throw TimeoutException(
                            'The authentication process took too long.');
                      }),
                    ]);
                    devtools.log("res: $res");
                    // if success, create cart
                    if (res.statusCode == 200) {
                      devtools.log("code: ${res.body}");
                      final body = jsonDecode(res.body) as Map<String, dynamic>;
                      cart.setID(body['id'].toString());
                      final mqttSuccess = await mqtt.establish(
                          auth.user_id, body['token'].toString());
                      if (mqttSuccess) {
                        showSuccessDialog(context, 'Success');
                        await Future.delayed(
                            const Duration(milliseconds: 1500));
                        context.goNamed(cartRoute);
                      } else {
                        showAlertMassage(context, "Failed MQTT");
                        return;
                      }
                    } else {
                      showAlertMassage(context, "Failed HTTP");
                      return;
                    }
                  } on TimeoutException catch (e) {
                    errorMessage = e.toString();
                  } on Exception catch (e) {
                    String error = json
                        .decode(
                          e.toString().substring('Exception:'.length),
                        )['detail']
                        .toString();
                    devtools.log(error);
                    // switch (error) {
                    //   case 'Cart was not found':
                    //     errorMessage =
                    //         "Invalid Cart QR code,\n make sure you scan a valid QR code";
                    //     break;
                    //   case 'Cart-in-use':
                    //     errorMessage = "Cart not found";
                    //     break;
                    //   default:
                    //     // devtools.log('Error: $error');
                    errorMessage = "$error";
                    // break;
                    // }
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
