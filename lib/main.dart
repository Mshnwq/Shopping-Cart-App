import 'providers/cart_provider.dart';
// import 'services/auth.dart';
import 'theme/theme_controller.dart';
// import 'theme/typography.dart';
import 'theme/color_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'pages/all_pages.dart';
// import 'constants/routes.dart';
import 'route/go_router_provider.dart';

void main() async {
  // Ensure initialization of WidgetsBinding,
  // which is required to use platform channels to call the native code.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Check if the user is already logged in
  // await Auth().checkIfLoggedIn();
  // Providers for managing app state (shared state)
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider<ThemeProvider>(
  //         create: (_) => ThemeProvider(MyDarkTheme()),
  //       ),
  //       ChangeNotifierProvider<ThemeController>(
  //         create: (_) => ThemeController(),
  //       ),
  //       ChangeNotifierProvider<CartProvider>(
  //         create: (_) => CartProvider(),
  //       ),
  //       // ChangeNotifierProvider<UserProvider>(
  //       //   create: (_) => UserProvider(),
  //       // )
  //     ],
  //     child: ProviderScope(child: App()),
  //   ),
  // );
}

// class App extends StatelessWidget {
//   App({Key? key}) : super(key: key);
//   // using GoRouter to manage routes
//   // listen to Auth to manage authentication
//   // redirect: {return loginRoute;},
//   // redirect: (state) {
//   //   final isLogging = state.location == "/login";
//   //   bool isLoggedIn = Auth().isLoggedIn;
//   //   if (!isLogging && !isLoggedIn) return "/login";
//   //   if (isLogging && isLoggedIn) return "/home";
//   //   return null;
//   // },
//   final _router = ref.watch(goRouterProvider);
//   // final _router = GoRouter(
//   //   // refreshListenable: Auth(),
//   //   initialLocation: cartRoute,
//   //   routes: <GoRoute>[
//   //     GoRoute(
//   //       path: '/',
//   //       builder: (context, state) => const LogoPage(),
//   //     ),
//   //     GoRoute(
//   //       name: "login",
//   //       path: loginRoute,
//   //       builder: (context, state) => const LoginPage(),
//   //     ),
//   //     GoRoute(
//   //       name: "register",
//   //       path: registerRoute,
//   //       builder: (context, state) => const RegisterPage(),
//   //     ),
//   //     GoRoute(
//   //       name: "connect",
//   //       path: connectRoute,
//   //       builder: (context, state) => const ConnectPage(),
//   //       routes: [
//   //         GoRoute(
//   //           name: "QRscan",
//   //           path: qrScanRoute,
//   //           builder: (context, state) => const QRScannerPage(),
//   //         ),
//   //       ],
//   //     ),
//   //     GoRoute(
//   //       name: "cart",
//   //       path: cartRoute,
//   //       builder: (context, state) => const CartPage(),
//   //       routes: [
//   //         GoRoute(
//   //           name: "BarcodeScanner",
//   //           path: barcodeRoute,
//   //           builder: (context, state) => const BarcodeScannerPage(),
//   //         ),
//   //         GoRoute(
//   //           name: "ProdDir",
//   //           path: prodDirRoute,
//   //           builder: (context, state) => const ProductDirectoryPage(),
//   //         ),
//   //         GoRoute(
//   //           name: "checkout",
//   //           path: checkoutRoute,
//   //           builder: (context, state) => const CheckoutPage(),
//   //         ),
//   //       ],
//   //     ),
//   //   ],
//   //   errorBuilder: (context, state) => RouteErrorScreen(
//   //     errorMsg: state.error.toString(),
//   //     key: state.pageKey,
//   //   ),
//   // );

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       // routerConfig: _router,
//       debugShowCheckedModeBanner: false,
//       routerDelegate: _router.routerDelegate,
//       routeInformationParser: _router.routeInformationParser,
//       routeInformationProvider: _router.routeInformationProvider,
//     );
//     // localizationsDelegates: const [
//     //   AppLocalizations.delegate,
//     //   GlobalMaterialLocalizations.delegate,
//     //   GlobalWidgetsLocalizations.delegate,
//     //   GlobalCupertinoLocalizations.delegate,
//     // ],
//     // supportedLocales: const [
//     //   Locale('ar', ''),
//     //   Locale('en', ''),
//     // ],
//     // theme: context.read<ThemeProvider>().getAppTheme().theme);
//   }
// }

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
      title: 'Flutter Demo',
      themeMode: themeMode,
      // These themes are modifiable
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
