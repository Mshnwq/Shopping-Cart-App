import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/routes.dart';
import '../providers/cart_provider.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartShellPage extends ConsumerWidget {
  final Widget child;
  const CartShellPage({required this.child, Key? key}) : super(key: key);
  // ref.read(cartProvider).getData();

  // @override
  // State<CartShellPage> createState() => _CartShellPageState();
// }

// class _CartShellPageState extends State<CartShellPage> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
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
            title: Text('Cart ${cart.getCartState()} Mode',
                style: TextStyle(fontSize: 20)),
            // style: Theme.of.(context),
            actions: [
              Badge(
                badgeContent: Text(
                  cart.getCounter().toString(),
                  // "d",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                position: const BadgePosition(start: 30, bottom: 30),
                child: Container(
                  margin: const EdgeInsets.only(top: 5, right: 5),
                  alignment: Alignment.topRight,
                  child: const CartMenuWidget(),
                ),
              ),
            ],
          ),
        ),
        drawer: const MenuBar(),
        body: child,
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
