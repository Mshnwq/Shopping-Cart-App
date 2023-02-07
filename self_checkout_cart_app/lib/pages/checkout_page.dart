import 'package:badges/badges.dart';
// import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/routes.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/cart_provider.dart';
import '../providers/receipt_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_w;

// import 'dart:typed_data';
// import 'dart:io';
// import 'dart:ui' as ui;
import 'dart:developer' as devtools;

import 'cart_page.dart';

class CheckoutPage extends ConsumerWidget {
  CheckoutPage({super.key});
  // final GlobalKey _globalKey = GlobalKey();
  // Uint8List _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final receipt = ref.watch(receiptKeyProvider);
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = showCustomBoolDialog(
          context,
          "Disconnect Cart",
          "Are you Sure you want to disconnect this cart?",
          "Confirm",
        );
        if (await shouldLogout) {
          // Auth().closeSocket(); //TODO DDD
          context.goNamed(connectRoute);
        }
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), //height of appbar
          child: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text('Thank You {_user}', style: TextStyle(fontSize: 20)),
            actions: [
              Badge(
                badgeContent: Text(
                  cart.getCounter().toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                position: const BadgePosition(start: 30, bottom: 30),
                child: Container(
                  margin: const EdgeInsets.only(top: 5, right: 5),
                  alignment: Alignment.topRight,
                  child: const CartMenuWidget(isCheckout: true),
                ),
              ),
            ],
          ),
        ),
        drawer: const MenuBar(),
        body: Screenshot(
          controller: screenshotController,
          // child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40, top: 10),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              // onLongPress: () {
                              // devtools.log("tGGG");
                              // receipt.toggleIt();
                              // }, //TODO show mpre details
                              onTap: () => receipt.toggleIt(),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 5,
                                    ),
                                    borderRadius: BorderRadius.circular(35)),
                                child: QrImage(
                                  eyeStyle: const QrEyeStyle(
                                      color: Colors.black,
                                      eyeShape: QrEyeShape.circle),
                                  dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color: Colors.black),
                                  data: receipt.text ?? "Null",
                                  version: QrVersions.auto,
                                  size: 300.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: AnimatedOpacity(
                                opacity: (receipt.isToggle()) ? 1.00 : 0.00,
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  receipt.text ?? "Null",
                                  style: TextStyle(
                                      color: Colors.blueGrey.shade800,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Consumer(builder:
                    (BuildContext context, WidgetRef ref, Widget? child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.getCounter(),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      text: TextSpan(
                                          text: 'Name: ',
                                          style: TextStyle(
                                              color: Colors.blueGrey.shade800,
                                              fontSize: 16.0),
                                          children: [
                                            TextSpan(
                                                text:
                                                    '${cart.getItems()[index].name}\n',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                    ),
                                    RichText(
                                      maxLines: 1,
                                      text: TextSpan(
                                          text: 'Quantity: ',
                                          style: TextStyle(
                                              color: Colors.blueGrey.shade800,
                                              fontSize: 16.0),
                                          children: [
                                            TextSpan(
                                                text: '1\n',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                    ),
                                    RichText(
                                      maxLines: 1,
                                      text: TextSpan(
                                          text: 'Price: ' r"SAR",
                                          style: TextStyle(
                                              color: Colors.blueGrey.shade800,
                                              fontSize: 16.0),
                                          children: [
                                            TextSpan(
                                                text:
                                                    '${cart.getItems()[index].price}\n',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     GoRouter.of(context).push(
                              //         '/prod_detail/${cart.getItems()[index].name}');
                              //   },
                              //   icon: const Icon(Icons.more_vert),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Column(
                children: [
                  ReusableWidget(
                    title: 'Sub-Total',
                    value: r'SAR' +
                        (cart.getTotalPrice()?.toStringAsFixed(2) ?? '0'),
                  ),
                ],
              ),
            ],
          ),
          // ),
        ),
        bottomNavigationBar: Container(
          height: 60,
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            child: InkWell(
              onLongPress: () => context.goNamed(cartRoute),
              onTap: () async => _getPDF(),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.share,
                      color: Theme.of(context).indicatorColor,
                      size: 30,
                    ),
                    const Text('Share Receipt'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _getPDF() async {
    // await screenshotController.capture().then((value) => _printPDF(value));
    final Uint8List? screenShot = await screenshotController.capture();
    if (screenShot == null) return;
    pdf_w.Document pdf = pdf_w.Document();
    pdf.addPage(
      pdf_w.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pdf_w.Expanded(
            // return pdf_w.Image(
            child: pdf_w.Image(
              pdf_w.MemoryImage(screenShot),
              fit: pdf_w.BoxFit.contain,
              alignment: pdf_w.Alignment.centerRight,
            ),
          );
        },
      ),
    );

    String tempPath = (await getTemporaryDirectory()).path;
    String fileName = "TEST";
    // print('$tempPath/$fileName.PAP');
    // if (await Permission.storage.request().isGranted) {
    if (true) {
      // print('$tempPath/$fileName.png');
      File pdfFile = await File('$tempPath/$fileName.pdf').create();
      if (pdfFile != null) {
        pdfFile.writeAsBytesSync(await pdf.save());
        await Share.shareXFiles([XFile(pdfFile.path)]);
        // print("SUCESSS");
      } else {
        Fluttertoast.showToast(msg: "Sharing Failed");
      }
    }
  }
}
