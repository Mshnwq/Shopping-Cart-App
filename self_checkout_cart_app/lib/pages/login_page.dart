import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import 'dart:developer' as devtools show log;
import '/services/env.dart' as env;

class LoginPage extends ConsumerStatefulWidget {
// class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  // const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
  // State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
// class _LoginPageState extends State<LoginPage> {
  // controller objects that connect between button and text field
  // late final TextEditingController _email = TextEditingController();
  late final TextEditingController _email;
  // late final TextEditingController _passwd = TextEditingController();
  late final TextEditingController _passwd;

  @override
  void initState() {
    _email = TextEditingController();
    _passwd = TextEditingController();
    super.initState();
    ref.read(authProvider);
  }

  @override
  void dispose() {
    _email.dispose();
    _passwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget build(BuildContext context, WidgetRef ref) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: appTheme.green,
        title: const Text("Self Check Out Cart"),
      ),
      // body: showPage(context)
      body:
          //   child: FutureBuilder(
          //     future: Firebase.initializeApp(
          //       options: DefaultFirebaseOptions.currentPlatform,
          //     ),
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasError) {
          //         switch (snapshot.connectionState) {
          //           case ConnectionState.done:
          //             return showPage(appTheme);
          //           default:
          //             return const Center(child: CircularProgressIndicator());
          //         }
          //       } else {
          //         return const Text("call returns error :");
          //       }
          //     },
          //   ),
          // ),
          //       );
          // }

          // Widget showPage(context) {
          // return Center(
          Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              textAlign: TextAlign.center,
              controller: _email,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter Email or Username',
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _passwd,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter Password',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final String email = _email.text;
                final String passwd = _passwd.text;
                try {
                  devtools.log("email $email");
                  devtools.log("pass $passwd");
                  bool isLoggedIn = await auth.login(context, email, passwd);
                  // bool isLoggedIn = true;
                  // Auth().establishWebSocket(env.sock);
                  if (!isLoggedIn) {
                    showAlertMassage(context, "Failed to log in");
                    return;
                  }
                  context.goNamed(connectRoute);
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
                  devtools.log('Error: $e');
                  showAlertMassage(context, "$e");
                  //     break;
                  // }
                }
              },
              // style: appTheme.getButtonStyle,
              child: Text(
                'Log In',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            TextButton(
              onPressed: () => context.goNamed(registerRoute),
              child: Text(
                'Register',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            TextButton(
              onPressed: () => context.goNamed(logoRoute),
              child: Text(
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
