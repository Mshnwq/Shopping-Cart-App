// import 'package:badges/badges.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
// import '../theme/themes.dart';
import 'package:provider/provider.dart';
// import '../constants/routes.dart';
// import 'package:anim_search_bar/anim_search_bar.dart';
import 'dart:developer' as devtools;
import 'package:qr_flutter/qr_flutter.dart';
// import '../providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? receiptKey;
  bool receiptKeyTextState = false;

  @override
  void initState() {
    super.initState();
    loadReceiptKey();
  }

  void toggleReceiptTextState() {
    setState(() {
      receiptKeyTextState = !receiptKeyTextState;
    });
  }

  void loadReceiptKey() async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      receiptKey = "123456";
    });
  }

  @override
  Widget build(BuildContext context) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    return Scaffold(
      // drawer: MenuBar(),
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(60), //height of appbar
      //   child: AppBar(
      //     centerTitle: true,
      //     // backgroundColor: appTheme.green,
      //     title: Text(
      //       'Thank You _username',
      //       // style: appTheme.setButtonTextStyle(18, 1),
      //     ),
      //   ),
      // ),
      //floating action button position to center
      body: Column(
        children: [
          Expanded(
            flex: 4, //?
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onLongPress: () => toggleReceiptTextState(), //TODO
                            onTap: () => toggleReceiptTextState(),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 5,
                                  ),
                                  borderRadius: BorderRadius.circular(40)),
                              child: QrImage(
                                eyeStyle: const QrEyeStyle(
                                    color: Colors.black,
                                    eyeShape: QrEyeShape.circle),
                                dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle,
                                    color: Colors.black),
                                data: receiptKey ?? "Null",
                                version: QrVersions.auto,
                                size: 300.0,
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: AnimatedOpacity(
                                opacity: (receiptKeyTextState) ? 1.00 : 0.00,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  receiptKey ?? "Null",
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavBar(), //TODO for is checkout
    );
  }
}
