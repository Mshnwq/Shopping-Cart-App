import 'package:badges/badges.dart' as badge;
// import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import '../widgets/menu_bar.dart' as menu;
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/routes.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/cart_provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mqtt_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_w;

import 'dart:developer' as devtools;

import 'cart_page.dart';

class CheckoutPage extends ConsumerWidget {
  CheckoutPage({super.key});
  // final GlobalKey _globalKey = GlobalKey();
  // Uint8List _imageFile;

  // Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final mqtt = ref.watch(mqttProvider);
    final receipt = ref.watch(receiptProvider);

    return WillPopScope(
      onWillPop: () async {
        final shouldDisconnect = await customDialog(
          context: context,
          title: 'Disconnect Cart?',
          message: 'Are you Sure you want to disconnect this cart?',
          buttons: [
            ButtonArgs(
              text: 'Disconnect',
              value: true,
            ),
            ButtonArgs(
              text: 'Cancel',
              value: false,
            ),
          ],
        );
        if (await shouldDisconnect) {
          mqtt.disconnect();
          context.goNamed(connectRoute);
        }
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), //height of appbar
          child: Builder(builder: (BuildContext context) {
            return AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Text(
                'Thank You {$auth.username}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.background),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.background,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              actions: [
                badge.Badge(
                  badgeContent: Text(
                    cart.getCounter().toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontWeight: FontWeight.bold),
                  ),
                  position: const badge.BadgePosition(start: 30, bottom: 30),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5, right: 5),
                    alignment: Alignment.topRight,
                    child: const CartMenuWidget(isCheckout: true),
                  ),
                ),
              ],
            );
          }),
        ),
        drawer: const menu.MenuBar(),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      width: 5,
                                    ),
                                    borderRadius: BorderRadius.circular(5)),
                                child: QrImage(
                                  eyeStyle: const QrEyeStyle(
                                      color: Colors.black,
                                      eyeShape: QrEyeShape.square),
                                  dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
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
          color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.background,
                      size: 30,
                    ),
                    Text(
                      'Share Receipt',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.background,
                          ),
                    ),
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
