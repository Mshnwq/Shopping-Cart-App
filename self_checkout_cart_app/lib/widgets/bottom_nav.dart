import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import '../constants/routes.dart';
import 'all_widgets.dart';
import 'dart:developer' as devtools show log;

class BottomNavigationWidget extends ConsumerStatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<BottomNavigationWidget> createState() =>
      _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState
    extends ConsumerState<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    final position = ref.watch(dashboardControllerProvider);

    return BottomNavigationBar(
      // backgroundColor: Colors.blueGrey,
      currentIndex: position,
      onTap: (value) => _onTap(value),
      selectedItemColor: Theme.of(context).indicatorColor,
      unselectedItemColor: Theme.of(context).indicatorColor,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      items: [
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.receipt_long,
            color: Theme.of(context).focusColor,
            size: 35,
          ),
          icon: Icon(
            Icons.receipt_long,
            color: Theme.of(context).indicatorColor,
            size: 30,
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.find_in_page_outlined,
            color: Theme.of(context).focusColor,
            size: 35,
          ),
          icon: Icon(
            Icons.find_in_page_outlined,
            color: Theme.of(context).indicatorColor,
            size: 30,
          ),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.live_help_outlined,
            color: Theme.of(context).focusColor,
            size: 35,
          ),
          icon: Icon(
            Icons.live_help_outlined,
            color: Theme.of(context).indicatorColor,
            size: 30,
          ),
          label: 'Guide',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.shopping_cart_checkout,
            color: Theme.of(context).focusColor,
            size: 35,
          ),
          icon: Icon(
            Icons.shopping_cart_checkout,
            color: Theme.of(context).indicatorColor,
            size: 30,
          ),
          label: 'Checkout',
        ),
      ],
    );
  }

  void _onTap(int index) async {
    if (index == 3) {
      final shouldCheckout = await showCustomBoolDialog(
        context,
        "Checkout Cart",
        "Are you Sure you want to checkout?",
        "Confirm Checkout",
      );
      if (shouldCheckout) {
        try {
          http.Response httpRes =
              await ref.watch(authProvider).getAuthReq('api/v1/bill/secret');
          if (httpRes.statusCode == 200) {
            // if (true) {
            final body = json.decode(httpRes.body);
            ref.watch(receiptProvider).setText(body.toString());
            // ref.watch(receiptProvider).setText('cred5f6g7f67d445f6g');
            ref.watch(cartProvider).setCartState('checkout');
            context.goNamed(checkoutRoute);
          } else {
            throw Exception(httpRes.statusCode.toString());
            // throw Exception('oops');
          }
        } catch (e) {
          bool isRetry = await showCustomBoolDialog(
            context,
            "Server error",
            "$e",
            "Retry",
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
    } else {
      ref.read(dashboardControllerProvider.notifier).setPosition(index);
      switch (index) {
        case 0:
          ref.watch(cartProvider).setCartState('active');
          context.goNamed(cartRoute);
          break;
        case 1:
          ref.watch(cartProvider).setCartState('active');
          context.goNamed(prodDirRoute);
          break;
        case 2:
          showSuccussSnackBar(context);
          break;
        default:
      }
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, int>(
        (ref) => DashboardController(0));

class DashboardController extends StateNotifier<int> {
  DashboardController(super.state);

  void setPosition(int value) {
    state = value;
  }
}
