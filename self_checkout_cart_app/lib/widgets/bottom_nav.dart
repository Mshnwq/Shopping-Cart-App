// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../constants/routes.dart';
// import 'all_widgets.dart';

// class BottomNavBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       // return Container(
//       //   height: 50,
//       //   decoration: const BoxDecoration(
//       //     color: Colors.green,
//       //     borderRadius: BorderRadius.only(
//       //       topLeft: Radius.circular(30),
//       //       bottomLeft: Radius.circular(30),
//       //       topRight: Radius.circular(30),
//       //       bottomRight: Radius.circular(30),
//       //     ),
//       //   ),
//       color: Colors.green,
//       shape: CircularNotchedRectangle(), //shape of notch
//       notchMargin: 5, //notche margin between floating button and bottom appbar
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           IconButton(
//             enableFeedback: false,
//             onPressed: () {
//               // context.goNamed(cartRoute);
//             },
//             icon: const Icon(
//               Icons.receipt_long,
//               color: Colors.white,
//               size: 35,
//             ),
//           ),
//           IconButton(
//             enableFeedback: false,
//             onPressed: () {
//               context.goNamed(prodDirRoute);
//             },
//             icon: const Icon(
//               Icons.find_in_page_outlined,
//               color: Colors.white,
//               size: 35,
//             ),
//           ),
//           IconButton(
//             enableFeedback: false,
//             onPressed: () {},
//             icon: const Icon(
//               Icons.shopping_cart_checkout,
//               color: Colors.green,
//               size: 1,
//             ),
//           ),
//           IconButton(
//             enableFeedback: false,
//             onPressed: () {
//               showSuccussSnackBar(context);
//             },
//             icon: const Icon(
//               Icons.live_help_outlined,
//               color: Colors.white,
//               size: 35,
//             ),
//           ),
//           IconButton(
//             enableFeedback: false,
//             onPressed: () async {
//               final shouldCheckout = showCustomBoolDialog(
//                 context,
//                 "Checkout Cart",
//                 "Are you Sure you want to checkout?",
//                 "Confirm Checkout",
//               );
//               if (await shouldCheckout) {
//                 context.goNamed(checkoutRoute);
//               }
//             },
//             icon: const Icon(
//               Icons.shopping_cart_checkout,
//               color: Colors.white,
//               size: 35,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/routes.dart';
import 'all_widgets.dart';
// import '/dashboard_controller.dart';

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
            label: 'Cart'),
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
            label: 'Products'),
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
            label: 'Guide'),
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
            label: 'Checkout'),
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
        context.goNamed(checkoutRoute);
        // ref.read(dashboardControllerProvider.notifier).setPosition(index);
        ref.read(dashboardControllerProvider.notifier).setPosition(index);
      }
    } else {
      ref.read(dashboardControllerProvider.notifier).setPosition(index);
      switch (index) {
        case 0:
          context.goNamed(cartRoute);
          break;
        case 1:
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
