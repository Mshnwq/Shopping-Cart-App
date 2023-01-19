import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/all_widgets.dart';
import '../constants/routes.dart';
import '../services/auth.dart';

enum _MenuValues { disconnect, checkout, print }

class CartMenuWidget extends ConsumerStatefulWidget {
  const CartMenuWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<CartMenuWidget> createState() => _CartMenuWidgetState();
}

class _CartMenuWidgetState extends ConsumerState<CartMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.shopping_cart),
      itemBuilder: (context) => [
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
      ],
      onSelected: (value) async {
        switch (value) {
          case _MenuValues.checkout:
            final shouldCheckout = showCustomBoolDialog(
              context,
              "Checkout Cart",
              "Are you Sure you want to checkout?",
              "Confirm Checkout",
            );
            if (await shouldCheckout) {
              ref.read(dashboardControllerProvider.notifier).setPosition(3);
              context.goNamed(checkoutRoute);
            }
            break;
          case _MenuValues.print:
            print("print"); //TODO
            break;
          case _MenuValues.disconnect:
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
        }
      },
      offset: const Offset(0, 50),
    );
  }
}
