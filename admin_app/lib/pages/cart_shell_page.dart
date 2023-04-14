import 'dart:convert';

import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as devtools;
import 'package:http/http.dart' as http;

class CartShellPage extends ConsumerWidget {
  const CartShellPage({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return WillPopScope(
      onWillPop: () async {
        final shouldDisconnect = showCustomBoolDialog(
          context,
          "Disconnect Cart",
          "Are you Sure you want to disconnect this cart?",
          "Confirm",
        );
        if (await shouldDisconnect) {
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
            title: Text(
              'Cart ID ${auth.cart_id}',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        body: child,
        // bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
