import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Item {
  final String barcode;
  final String name;
  final String unit;
  final double price;
  // final Uint8List image;
  final String image;

  const Item(
      {required this.barcode,
      required this.name,
      required this.unit,
      required this.price,
      required this.image});

  Map toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'unit': unit,
      'price': price,
      'image': image,
    };
  }
}
