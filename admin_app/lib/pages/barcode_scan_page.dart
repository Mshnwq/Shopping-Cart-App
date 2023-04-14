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

  BarcodeScannerPage({
    Key? key,
    required this.action,
  }) : super(key: key);

  ScannerController scannerController = ScannerController();
  bool _canScan = true;
  bool _awaitHttp = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    devtools.log("action $action");

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
                  try {
                    http.Response httpRes = await auth.postReq(
                      '/api/v1/item/admin_$action',
                      body: <String, String>{
                        'barcode': barCode.toString(),
                        'qrcode': auth.cart_id,
                        'process_id': '100001',
                      },
                    );
                    devtools.log("code: ${httpRes.statusCode}");
                    // if success, add item to cart and exit refresh page
                    if (httpRes.statusCode == 200) {
                      context.goNamed(cartRoute);
                    } else {
                      bool isRetry = await showCustomBoolDialog(
                        context,
                        "ERROR",
                        "${httpRes.body}",
                        "Ok",
                      );
                      if (isRetry) {
                        context.goNamed(cartRoute);
                      } else {
                        context.goNamed(cartRoute);
                      }
                    }
                  } catch (e) {
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
                      GoRouter.of(context).pop();
                    }
                  }
                } else {
                  GoRouter.of(context).pop();
                }
              }
            },
          ),
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
