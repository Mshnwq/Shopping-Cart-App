import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/all_pages.dart';
import '../route/go_router_notifier.dart';
import '../constants/routes.dart';

// final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
// final GlobalKey<NavigatorState> _shellNavigator =
// GlobalKey(debugLabel: 'shell');

final goRouterProvider = Provider<GoRouter>((ref) {
  bool isDuplicate = false;
  final notifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    // navigatorKey: _rootNavigator,
    initialLocation: '/',
    // refreshListenable: notifier,
    // redirect: (context, state) {
    //   final isGoingToLogin = state.subloc == '/login';
    //   final isLoggedIn = notifier.isLoggedIn;

    //   if (!isLoggedIn && !isGoingToLogin && !isDuplicate) {
    //     isDuplicate = true;
    //     return '/';
    //   }
    //   if (isLoggedIn) {
    //     isDuplicate = true;
    //     return '/connect';
    //   }
    //   if (isDuplicate) {
    //     isDuplicate = false;
    //   } else {
    //     return '/';
    //   }
    //   return null;
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
        builder: (context, state) => const ConnectPage(),
        routes: [
          GoRoute(
            path: "QRscan",
            name: qrScanRoute,
            builder: (context, state) => const QRScannerPage(),
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
              // final id = state.params['id'].toString();
              return NoTransitionPage(
                  child: ProductDetailPage(
                id: state.params['id'].toString(),
                key: state.pageKey,
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
              return NoTransitionPage(
                child: BarcodeScannerPage(
                  key: state.pageKey,
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
