import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../services/auth.dart';
import '../services/mqtt.dart';
import '../services/api.dart';
import '../providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import '../services/socket.dart';
import '../widgets/all_widgets.dart';
import 'dart:developer' as devtools;

// QR code scanner imports
import '../services/qrcode_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:image_picker/image_picker.dart';

class QRScannerPage extends ConsumerWidget {
  QRScannerPage({Key? key}) : super(key: key);

// class _QRScannerPageState extends State<QRScannerPage> {
  ScannerController scannerController = ScannerController();

  bool _canScan = true;

  // @override
  // void initState() {
  //   super.initState();
  //   if (!scannerController.cameraController.isStarting) {
  //     scannerController.cameraController.start();
  //   }
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final mqtt = ref.watch(mqttProvider);

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        // children: [
        //   // FunctionBar(
        //     // scannerController: scannerController,
        //   // ),
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
                  // devtools.log("qrcode: ${qrCode.toString()}");
                  try {
                    http.Response res = await auth.postAuthReq(
                      '/api/v1/cart/connect',
                      body: httpBody,
                    );
                    // devtools.log("code: ${res.statusCode}");
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
