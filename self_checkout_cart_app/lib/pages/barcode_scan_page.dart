import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
import '../widgets/all_widgets.dart';
// import '../db/db_helper.dart';
// import '../services/api.dart';
import '../services/auth.dart';
import 'package:http/http.dart' as http;
// import '../models/cart_model.dart';
import '../models/item_model.dart';
import '../providers/cart_provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;

// Barcode scanner imports
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qrcode_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/connectivity_service.dart';

class BarcodeScannerPage extends ConsumerWidget {
  BarcodeScannerPage({Key? key}) : super(key: key);
  // @override
  // State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
// }

// class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  // DBHelper dbHelper = DBHelper();
  ScannerController scannerController = ScannerController();

  List<Item> products = [
    Item(
        name: 'Apple',
        unit: 'Kg',
        price: 20,
        image: 'assets/images/apple.jpeg'),
    Item(
        name: 'Mango',
        unit: 'Doz',
        price: 30,
        image: 'assets/images/mango.jfif'),
    Item(
        name: 'Banana',
        unit: 'Doz',
        price: 10,
        image: 'assets/images/banana.jpeg'),
  ];

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
    // final cart = Provider.of<CartProvider>(context);
    // ref.read(cartListProvider).getData();
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    // void saveData(int index) {
    //   dbHelper
    //       .insert(
    //     Cart(
    //       id: index,
    //       productId: index.toString(),
    //       productName: products[index].name,
    //       initialPrice: products[index].price,
    //       productPrice: products[index].price,
    //       quantity: ValueNotifier(1),
    //       unitTag: products[index].unit,
    //       image: products[index].image,
    //     ),
    //   )
    //       .then((value) {
    //     cart.addTotalPrice(products[index].price.toDouble());
    //     cart.addCounter();
    //     devtools.log('Product Added to cart');
    //   }).onError((error, stackTrace) {
    //     devtools.log(error.toString());
    //   });
    // }

    saveData(int index) {
      // dbHelper
      //     .insert(
      //   Cart(
      //     id: index,
      //     productId: index.toString(),
      //     productName: products[index].name,
      //     initialPrice: products[index].price,
      //     productPrice: products[index].price,
      //     quantity: ValueNotifier(1),
      //     unitTag: products[index].unit,
      //     image: products[index].image,
      //   ),
      // )
      cart.addItem(products[index]);
      // .then((value) {
      // cart.addTotalPrice(products[index].price.toDouble());
      // cart.addCounter();
      devtools.log('Product Added to cart');
      // }).onError((error, stackTrace) {
      // devtools.log(error.toString());
      // });
    }

    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    return WillPopScope(
      onWillPop: () async {
        cart.setCartState("active");
        return true;
      },
      child: Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          // children: [
          //   FunctionBar(
          //     scannerController: scannerController,
          //   ),
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
                    var httpBody = <String, String>{
                      'barcode': barCode.toString(),
                    };
                    try {
                      devtools.log("barcode: $barCode.toString()}");
                      http.Response res = await auth.postAuthReq(
                        '/api/v1/item/add',
                        body: httpBody,
                      );
                      devtools.log("code: ${res.statusCode}");
                      // if success, add item to cart and exit refresh page
                      if (res.statusCode == 200) {
                        devtools.log("code: ${res.body}");
                        final body =
                            jsonDecode(res.body) as Map<String, dynamic>;
                        // cart.addItem(body['item']);
                        cart.addItem(products[cart.getCounter()]);
                      }
                    } catch (e) {
                      devtools.log("$e");
                    }
                    cart.setCartState("active");
                    context.goNamed(cartRoute);
                  } else {
                    _canScan = true;
                    cart.setCartState("active");
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
      ),
    );
  }

  void allowScan() {
    _canScan = true;
  }
}

// class FunctionBar extends StatefulWidget {
//   const FunctionBar({
//     Key? key,
//     required this.scannerController,
//   }) : super(key: key);
//   final ScannerController scannerController;

//   @override
//   State<FunctionBar> createState() => _FunctionBarState();
// }

// // TODO

// class _FunctionBarState extends State<FunctionBar> {
//   void logInUsingPhoto() async {
//     final XFile? image =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//     devtools.log('image: ${image.toString()}');
//     devtools.log('image: ${image}');
//     String? res = await widget.scannerController.scanPhoto(image.path);
//     devtools.log('Parse result: ${res.toString()}');
//     devtools.log('Parse result: ${res}');
//     if (!mounted) return;
//     if (res == null) {
//       return;
//     }
//   }

//   void toggleFlash(ScannerController controller) {
//     controller.toggleFlash();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     ScannerController controller = widget.scannerController;
//     return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Expanded(
//               flex: 3,
//               child: FloatingActionButton(
//                   heroTag: "galleryButton",
//                   onPressed: () => logInUsingPhoto(),
//                   backgroundColor: Color.fromARGB(100, 72, 181, 114),
//                   child: const Icon(Icons.photo_album))),
//           Expanded(
//               flex: 2,
//               child: FloatingActionButton(
//                 heroTag: "flashButton",
//                 onPressed: () => toggleFlash(controller),
//                 backgroundColor: (controller.isFlashOn)
//                     ? const Color.fromARGB(211, 255, 255, 255)
//                     : const Color.fromARGB(100, 72, 181, 114),
//                 child: (controller.isFlashOn)
//                     ? const Icon(
//                         Icons.flashlight_on_rounded,
//                         color: Color.fromARGB(255, 72, 184, 121),
//                       )
//                     : const Icon(Icons.flashlight_on_rounded),
//               )),
//         ]);
//   }
// }
