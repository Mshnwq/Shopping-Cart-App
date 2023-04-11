import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import 'dart:developer' as devtools;

// QR code scanner imports
import '../services/qrcode_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends ConsumerWidget {
  QRScannerPage({Key? key}) : super(key: key);

  ScannerController scannerController = ScannerController();
  bool _canScan = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

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
                final connectCart = await showQRDialog(context, qrCode);
                if (connectCart) {
                  var httpBody = <String, String>{
                    'qrcode': qrCode.toString(),
                  };
                  devtools.log("qrcode: ${qrCode.toString()}");
                  try {
                    http.Response res = await auth.postAuthReq(
                      '/api/v1/cart/connect',
                      body: httpBody,
                    );
                    // if success, create cart
                    if (res.statusCode == 200) {
                      devtools.log("code: ${res.body}");
                      context.goNamed(cartRoute);
                    }
                  } catch (e) {
                    devtools.log("$e");
                  }
                } else {
                  _canScan = true;
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
                  "Scan a Cart QR code",
                  style: TextStyle(
                      // color: appTheme.textColor,
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
