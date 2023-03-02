// import 'services/auth.dart';
import 'theme/theme_controller.dart';
import 'theme/color_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
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
    // localizationsDelegates: const [
    //   AppLocalizations.delegate,
    //   GlobalMaterialLocalizations.delegate,
    //   GlobalWidgetsLocalizations.delegate,
    //   GlobalCupertinoLocalizations.delegate,
    // ],
    // supportedLocales: const [
    //   Locale('ar', ''),
    //   Locale('en', ''),
    // ],
  }
}
