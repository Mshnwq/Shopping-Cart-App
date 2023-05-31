import 'theme/theme_controller.dart';
import 'theme/color_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'route/go_router_provider.dart';

void main() {
  // Ensure initialization of WidgetsBinding,
  // which is required to use platform channels to call the native code.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(child: MyApp()),
  );
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Check if the user is already logged in
  // await Auth().checkIfLoggedIn();
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
// TODO: to fix build context in Barcode scan !
// https://www.acodeblog.com/post/2022/5/29/flutter-showdialog-without-context-using-the-navigatorkey
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
      title: 'Flutter Demo',
      themeMode: themeMode,
      // These themes are modifiable
      theme: lightTheme,
      // darkTheme: darkTheme,
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
