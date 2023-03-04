import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import 'dart:developer' as devtools;

import '../services/qrcode_scanner.dart';
// import '../services/connectivity_service.dart';
// QR code scanner imports
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:image_picker/image_picker.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);
  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  ScannerController scannerController = ScannerController();

  bool _canScan = true;

  @override
  void initState() {
    super.initState();
    if (!scannerController.cameraController.isStarting) {
      scannerController.cameraController.start();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
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
                  final connectCart = showQRDialog(context, qrCode);
                  if (await connectCart) {
                    if (qrCode == 'Welcome') {
                      //try: TODO endpoint try catch
                      context.goNamed(prodDirRoute);
                    } else {
                      showCustomDialog(
                        context,
                        "Invalid QR Code",
                        qrCode,
                        "Sure...",
                      );
                      _canScan = true;
                    }
                  } else {
                    GoRouter.of(context).pop();
                  }
                }
              }),
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
