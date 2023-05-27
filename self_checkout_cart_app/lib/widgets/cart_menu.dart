import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/all_widgets.dart';
import '../constants/routes.dart';
import '../providers/cart_provider.dart';
import '../providers/mqtt_provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;

enum _MenuValues { disconnect, checkout, print }

class CartMenuWidget extends ConsumerStatefulWidget {
  const CartMenuWidget({Key? key, this.isCheckout = false}) : super(key: key);
  final bool isCheckout;

  @override
  ConsumerState<CartMenuWidget> createState() => _CartMenuWidgetState();
}

class _CartMenuWidgetState extends ConsumerState<CartMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.shopping_cart),
      itemBuilder: (context) {
        if (!widget.isCheckout) {
          return [
            PopupMenuItem(
              value: _MenuValues.checkout,
              child: Row(
                children: const [
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Checkout")
                ],
              ),
            ),
            PopupMenuItem(
              value: _MenuValues.print,
              child: Row(
                children: const [
                  Icon(
                    Icons.print,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Print")
                ],
              ),
            ),
            PopupMenuItem(
              value: _MenuValues.disconnect,
              child: Row(
                children: const [
                  Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Disconnect")
                ],
              ),
            ),
          ];
        } else {
          return [
            PopupMenuItem(
              value: _MenuValues.print,
              child: Row(
                children: const [
                  Icon(
                    Icons.print,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Print")
                ],
              ),
            ),
            PopupMenuItem(
              value: _MenuValues.disconnect,
              child: Row(
                children: const [
                  Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Disconnect")
                ],
              ),
            ),
          ];
        }
      },
      onSelected: (value) async {
        switch (value) {
          case _MenuValues.checkout:
            final shouldCheckout = await customDialog(
              context: context,
              title: "Checkout Cart",
              message: "Are you Sure you want to checkout?",
              buttons: [
                const ButtonArgs(
                  text: 'Confirm',
                  value: true,
                ),
                const ButtonArgs(
                  text: 'Cancel',
                  value: false,
                ),
              ],
            );
            if (await shouldCheckout) {
              try {
                http.Response httpRes = await ref
                    .watch(authProvider)
                    .getAuthReq('api/v1/bill/secret');
                if (httpRes.statusCode == 200) {
                  final body = json.decode(httpRes.body);
                  ref.watch(receiptProvider).setText(body.toString());
                  ref.watch(cartProvider).setCartState('checkout');
                  context.goNamed(checkoutRoute);
                } else {
                  throw Exception(httpRes.statusCode.toString());
                }
              } catch (e) {
                bool isRetry = await customDialog(
                  context: context,
                  title: "Server error",
                  message: "$e",
                  buttons: [
                    const ButtonArgs(
                      text: 'Retry',
                      value: true,
                    ),
                  ],
                );
                if (isRetry) {
                  ref.watch(cartProvider).setCartState("active");
                  context.goNamed(cartRoute);
                } else {
                  ref.watch(cartProvider).setCartState("active");
                  context.goNamed(cartRoute);
                }
              }
            }
            break;
          case _MenuValues.print:
            print("print"); //TODO
            print("print"); //TODO
            print("print"); //TODO
            print("print"); //TODO
            break;
          case _MenuValues.disconnect:
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
              ref.read(mqttProvider).disconnect();
              context.goNamed(connectRoute);
            }
        }
      },
      offset: const Offset(0, 50),
    );
  }
}
