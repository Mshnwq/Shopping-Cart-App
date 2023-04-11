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
          try {
            http.Response res = await auth.postAuthReq(
              '/api/v1/cart/disconnect',
            );
            if (res.statusCode == 200) {
              context.goNamed(connectRoute);
            }
          } catch (e) {
            devtools.log("$e");
          }
        }
        return false;
      },
      child: StreamBuilder<String>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // handle loading
            if (json.decode(snapshot.data!)['trigger']) {
              devtools
                  .log('AWAITING ADMINISTRATOR ${snapshot.data.toString()}');
              return const Text('AWAITING ADMINISTRATOR');
            } else {
              return cartShell(context, ref);
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            // handle data
            return cartShell(context, ref);
          } else if (snapshot.hasError) {
            // handle error (note: snapshot.error has type [Object?])
            final error = snapshot.error!;
            return Text(error.toString());
          } else {
            // uh, oh, what goes here?
            return const Text('Some error occurred - welp!');
          }
        },
      ),
    );
  }

  Widget cartShell(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), //height of appbar
        child: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            'Cart Mode',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
