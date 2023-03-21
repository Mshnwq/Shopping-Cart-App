import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final receiptProvider = ChangeNotifierProvider((ref) => Receipt());

class Receipt with ChangeNotifier {
  String? _text = 'Error';
  String? get text => _text;

  bool _toggle = false;
  bool get toggle => _toggle;

  String? getText() => _text;
  void setText(String? newText) => _text = newText;

  bool isToggle() => toggle;
  void toggleIt() {
    _toggle = !_toggle;
    notifyListeners();
  }
}
