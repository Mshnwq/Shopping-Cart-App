import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import '../route/endpoint_navigate.dart';
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
            color: Theme.of(context).colorScheme.primary,
            size: 35,
          ),
          icon: Icon(
            Icons.receipt_long,
            color: Theme.of(context).colorScheme.secondary,
            size: 30,
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.find_in_page_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 35,
          ),
          icon: Icon(
            Icons.find_in_page_outlined,
            color: Theme.of(context).colorScheme.secondary,
            size: 30,
          ),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.live_help_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 35,
          ),
          icon: Icon(
            Icons.live_help_outlined,
            color: Theme.of(context).colorScheme.secondary,
            size: 30,
          ),
          label: 'Guide',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.shopping_cart_checkout,
            color: Theme.of(context).colorScheme.primary,
            size: 35,
          ),
          icon: Icon(
            Icons.shopping_cart_checkout,
            color: Theme.of(context).colorScheme.secondary,
            size: 30,
          ),
          label: 'Checkout',
        ),
      ],
    );
  }

  void _onTap(int index) async {
    if (index == 3) {
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
          () => ref.watch(authProvider).getAuthReq('api/v1/bill/secret'),
          (context) => context.goNamed(checkoutRoute),
          "Failed to checkout cart",
          timeoutDuration: 3,
          successCallback: (res) async {
            String body = json.decode(res!.body).toString();
            ref.watch(receiptProvider).setText(body);
            ref.watch(cartProvider).setCartState("checkout");
            showSuccessDialog(context, "Checkout Success");
            await Future.delayed(const Duration(milliseconds: 1500));
          },
          errorCallback: () {
            ref.watch(cartProvider).setCartState("active");
          },
        );
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
