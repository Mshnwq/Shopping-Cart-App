import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/all_pages.dart';
import '../route/go_router_notifier.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;

// final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
// final GlobalKey<NavigatorState> _shellNavigator =
// GlobalKey(debugLabel: 'shell');

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    // navigatorKey: _rootNavigator,
    initialLocation: '/',
    refreshListenable: notifier,
    // redirect: (context, state) {
    //   final isLoggedIn = notifier.isLoggedIn;

    //   if (isLoggedIn) {
    //     return '/connect';
    //   } else {
    //     return '/';
    //   }
    // },
    routes: [
      GoRoute(
        path: '/',
        name: logoRoute,
        builder: (context, state) => const LogoPage(),
      ),
      GoRoute(
        path: '/login',
        name: loginRoute,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/register",
        name: registerRoute,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: "/connect",
        name: connectRoute,
        builder: (context, state) => ConnectPage(),
        routes: [
          GoRoute(
            path: "QRscan",
            name: qrScanRoute,
            builder: (context, state) => QRScannerPage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            CartShellPage(key: state.pageKey, child: child),
        routes: [
          GoRoute(
            path: '/cart',
            name: cartRoute,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: CartPage(
                  key: state.pageKey,
                ),
              );
            },
          ),
          GoRoute(
            path: '/prod_detail/:id',
            name: productDetailRoute,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: ProductDetailPage(
                key: state.pageKey,
                id: state.params['id'].toString(),
              ));
            },
          ),
          GoRoute(
            path: "/prod_dir",
            name: prodDirRoute,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: ProductDirectoryPage(
                  key: state.pageKey,
                ),
              );
            },
          ),
          GoRoute(
            path: "/barcode_scan",
            name: barcodeRoute,
            pageBuilder: (context, state) {
              // Get the parameters from the state object
              Map<String, dynamic> params = state.extra as Map<String, dynamic>;
              // devtools.log('${state.extra}');
              // Extract the individual parameters
              String action = params['action'] as String;
              String index = params['index'] as String;
              String barcodeToRead = params['barcodeToRead'] as String;

              return NoTransitionPage(
                child: BarcodeScannerPage(
                  key: state.pageKey,
                  // action: state.params['action'].toString(),
                  action: action,
                  // index: state.params['index'].toString(),
                  index: index,
                  // barcodeToRead: state.params['barcodeToRead'].toString()),
                  barcodeToRead: barcodeToRead,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: "/checkout",
        name: checkoutRoute,
        builder: (context, state) => CheckoutPage(),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(
      errorMsg: state.error.toString(),
      key: state.pageKey,
    ),
  );
});
