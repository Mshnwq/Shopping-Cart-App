import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/all_pages.dart';
import '../route/go_router_notifier.dart';
import '../constants/routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/',
        name: logoRoute,
        builder: (context, state) => const LogoPage(),
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
                child: LogoPage(
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
              // Extract the individual parameters
              String action = params['action'] as String;
              String index = params['index'] as String;
              String barcodeToRead = params['barcodeToRead'] as String;

              return NoTransitionPage(
                child: BarcodeScannerPage(
                  key: state.pageKey,
                  action: action,
                  index: index,
                  barcodeToRead: barcodeToRead,
                ),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(
      errorMsg: state.error.toString(),
      key: state.pageKey,
    ),
  );
});
