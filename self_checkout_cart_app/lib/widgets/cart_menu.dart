import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/all_widgets.dart';
import '../constants/routes.dart';
import '../providers/cart_provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import '../route/endpoint_navigate.dart';
import 'dart:developer' as devtools;

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
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final recp = ref.watch(receiptProvider);

    return PopupMenuButton(
      icon: Icon(
        Icons.shopping_cart,
        color: Theme.of(context).colorScheme.background,
      ),
      itemBuilder: (context) {
        if (!widget.isCheckout) {
          return [
            PopupMenuItem(
              value: _MenuValues.checkout,
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("Checkout")
                ],
              ),
            ),
            PopupMenuItem(
              value: _MenuValues.print,
              child: Row(
                children: [
                  Icon(
                    Icons.print,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("Print")
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
                children: [
                  Icon(
                    Icons.print,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("Print")
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
            if (shouldCheckout) {
              await EndpointAndNavigate(
                context,
                () => auth.getAuthReq('api/v1/bill/secret'),
                (context) => context.goNamed(checkoutRoute),
                "Failed to disconnect cart",
                timeoutDuration: 3,
                successCallback: (res) async {
                  String body = json.decode(res!.body).toString();
                  recp.setText(body);
                  ref.watch(cartProvider).setCartState("checkout");
                  showSuccessDialog(context, "Checkout Success");
                  await Future.delayed(const Duration(milliseconds: 1500));
                },
                errorCallback: () {
                  cart.setCartState("active");
                },
              );
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
              buttons: const [
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
            if (shouldDisconnect) {
              await EndpointAndNavigate(
                context,
                () => auth.postAuthReq('/api/v1/cart/disconnect'),
                (context) => context.goNamed(connectRoute),
                "Failed to disconnect cart",
                timeoutDuration: 3,
              );
            }
        }
      },
      offset: const Offset(0, 50),
    );
  }
}
