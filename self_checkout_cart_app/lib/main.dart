// import 'services/auth.dart';
import 'package:self_checkout_cart_app/pages/all_pages.dart';
import 'package:self_checkout_cart_app/services/auth.dart';

import 'theme/theme_controller.dart';
import 'theme/color_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'route/go_router_provider.dart';

// void main() async {
void main() {
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
// class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    // final auth = ref.watch(authProvider);

    // return MaterialApp(
    // title: 'Flutter Demo',
    // debugShowCheckedModeBanner: false,
    // theme: ThemeData(
    // primarySwatch: Colors.indigo,
    // ),
    // home: const LoginPage(),
    // home: const AuthScreen(),
    // home: AuthScreen(),
    // );
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

class AuthScreen extends ConsumerWidget {
  // const AuthScreen({Key? key}) : super(key: key);
  AuthScreen({Key? key}) : super(key: key);

  TextEditingController _email = TextEditingController();
  // final TextEditingController _email;
  TextEditingController _passwd = TextEditingController();

  // @override
  // void initState() {
  // _email = TextEditingController();
  // _passwd = TextEditingController();
  // super.initState();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const TextField(
              textAlign: TextAlign.center,
              // controller: _email,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter Email or Username',
              ),
            ),
            const TextField(
              textAlign: TextAlign.center,
              // controller: _passwd,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Enter Password',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // final String email = _email.text;
                // final String passwd = _passwd.text;
                try {
                  // bool isLoggedIn = await auth.login(context, email, passwd);
                  // bool isLoggedIn = await auth.login(context, '', '');
                  // Auth().establishWebSocket(env.sock);
                  // if (!isLoggedIn) {
                  // showAlertMassage(context, "Failed to log in");
                  return;
                  // }
                  // context.goNamed(connectRoute);
                  // } on Exception catch (e) {
                } catch (e) {
                  // switch (e) {
                  //   case 'User-not-found':
                  //     devtools.log('User-not-found');
                  //     showAlertMassage(context, "User not found");
                  //     break;
                  //   case 'Email-not-found':
                  //     devtools.log('Email-not-found');
                  //     showAlertMassage(context, "Email not found");
                  //     break;
                  //   case 'Wrong-cred':
                  //     devtools.log('Wrong-cred');
                  //     showAlertMassage(context, "Wrong Credentials");
                  //     break;
                  //   default:
                  // devtools.log('Error: $e');
                  // showAlertMassage(context, "$e");
                  //     break;
                  // }
                }
              },
              // style: appTheme.getButtonStyle,
              child: const Text(
                'Log In',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            TextButton(
              // onPressed: () => context.goNamed(registerRoute),
              onPressed: () => {},
              child: const Text(
                'Register',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            TextButton(
              // onPressed: () => context.goNamed(logoRoute),
              onPressed: () => {},
              child: const Text(
                'Back',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
