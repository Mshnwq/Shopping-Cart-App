import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Item {
  final String barcode;
  final String name;
  final String unit;
  final double price;
  int count;
  // final Uint8List image;
  final String image;

  Item(
      {required this.barcode,
      required this.name,
      required this.unit,
      required this.price,
      required this.count,
      required this.image});

  Map toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'unit': unit,
      'price': price,
      'count': count,
      'image': image,
    };
  }
}
