// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../pages/all_pages.dart';
// import '../route/go_router_notifier.dart';
// import '../route/named_route.dart';

// final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
// final GlobalKey<NavigatorState> _shellNavigator =
//     GlobalKey(debugLabel: 'shell');

// final goRouterProvider = Provider<GoRouter>((ref) {
//   bool isDuplicate = false;
//   final notifier = ref.read(goRouterNotifierProvider);

//   return GoRouter(
//     navigatorKey: _rootNavigator,
//     initialLocation: '/',
//     refreshListenable: notifier,
//     redirect: (context, state) {
//       final isLoggedIn = notifier.isLoggedIn;
//       final isGoingToLogin = state.subloc == '/login';

//       if (!isLoggedIn && !isGoingToLogin && !isDuplicate) {
//         isDuplicate = true;
//         return '/login';
//       }
//       if (isGoingToLogin && isGoingToLogin && !isDuplicate) {
//         isDuplicate = true;
//         return '/';
//       }

//       if (isDuplicate) {
//         isDuplicate = false;
//       }

//       return null;
//     },
//     routes: [
//       GoRoute(
//         path: '/home',
//         name: root,
//         builder: (context, state) => HomeScreen(key: state.pageKey),
//       ),
//       GoRoute(
//         path: '/login',
//         name: login,
//         builder: (context, state) => LoginScreen(key: state.pageKey),
//       ),
//       ShellRoute(
//           navigatorKey: _shellNavigator,
//           builder: (context, state, child) =>
//               DashboardScreen(key: state.pageKey, child: child),
//           routes: [
//             GoRoute(
//                 path: '/',
//                 name: home,
//                 pageBuilder: (context, state) {
//                   return NoTransitionPage(
//                       child: HomeScreen(
//                     key: state.pageKey,
//                   ));
//                 },
//                 routes: [
//                   GoRoute(
//                       parentNavigatorKey: _shellNavigator,
//                       path: 'productDetail/:id',
//                       name: productDetail,
//                       pageBuilder: (context, state) {
//                         final id = state.params['id'].toString();
//                         return NoTransitionPage(
//                             child: ProductDetailScreen(
//                           id: int.parse(id),
//                           key: state.pageKey,
//                         ));
//                       })
//                 ]),
//             GoRoute(
//               path: '/cart',
//               name: cart,
//               pageBuilder: (context, state) {
//                 return NoTransitionPage(
//                     child: CartScreen(
//                   key: state.pageKey,
//                 ));
//               },
//             ),
//             GoRoute(
//               path: '/setting',
//               name: setting,
//               pageBuilder: (context, state) {
//                 return NoTransitionPage(
//                     child: SettingScreen(
//                   key: state.pageKey,
//                 ));
//               },
//             )
//           ])
//     ],
//     errorBuilder: (context, state) => RouteErrorScreen(
//       errorMsg: state.error.toString(),
//       key: state.pageKey,
//     ),
//   );
// });

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
  // bool isDuplicate = false;
  final notifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    // navigatorKey: _rootNavigator,
    initialLocation: '/',
    // refreshListenable: notifier,
    // redirect: (context, state) {
    //   // final isGoingToLogin = state.subloc == '/login';
    //   final isLoggedIn = notifier.isLoggedIn;

    //   // if (!isLoggedIn && !isGoingToLogin && !isDuplicate) {
    //   // isDuplicate = true;
    //   // return '/';
    //   // }
    //   if (isLoggedIn) {
    //     // isDuplicate = true;
    //     return '/connect';
    //     // }
    //     // if (isDuplicate) {
    //     // isDuplicate = false;
    //   } else {
    //     return '/';
    //   }
    //   // return null;
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
          GoRoute(
            path: "/checkout",
            name: checkoutRoute,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: CheckoutPage(
                  key: state.pageKey,
                ),
              );
            },
          ),
          //   },),GoRoute(
          //   path: '/cart',
          //   name: cart,
          //   pageBuilder: (context, state) {
          //     return NoTransitionPage(
          //       child: CartScreen(
          //         key: state.pageKey,
          //       )
          //     );
          //   },
          // ),
          // GoRoute(
          //   name: "cart",
          //   path: cartRoute,
          //   builder: (context, state) => const CartPage(),
          //   routes: [
          //     GoRoute(
          //       name: "BarcodeScanner",
          //       path: barcodeRoute,
          //       builder: (context, state) => const BarcodeScannerPage(),
          //     ),
          //     GoRoute(
          //       name: "ProdDir",
          //       path: prodDirRoute,
          //       builder: (context, state) => const ProductDirectoryPage(),
          //     ),
          //     GoRoute(
          //       name: "checkout",
          //       path: checkoutRoute,
          //       builder: (context, state) => const CheckoutPage(),
          //     ),
          //   ],
          // ),
        ],
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(
      errorMsg: state.error.toString(),
      key: state.pageKey,
    ),
  );
});
