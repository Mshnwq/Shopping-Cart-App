import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:scan/scan.dart';

class ScannerController with ChangeNotifier {
  MobileScannerController _cameraController = MobileScannerController();
  bool get isFlashOn {
    return _cameraController.torchState.value == TorchState.on;
  }

  MobileScannerController get cameraController {
    return _cameraController;
  }

  set cameraController(MobileScannerController cameraController) {
    _cameraController = cameraController;
  }

  void toggleFlash() {
    _cameraController.toggleTorch();
    notifyListeners();
  }

  /// return [null] if the image does not contain qr code
  // Future<String?> scanPhoto(String path) async {
  //   // return await Scan.parse(path);
  //   // return "s";
  // }
}
