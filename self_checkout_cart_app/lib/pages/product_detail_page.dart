import 'package:flutter/material.dart';
import 'dart:developer' as devtools;

class ProductDetailPage extends StatefulWidget {
  final String id;
  const ProductDetailPage({required this.id, Key? key}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? receiptKey;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Product Detail : ${widget.id}')],
        ),
      ),
    );
  }
}
