import 'package:go_router/go_router.dart';
import '../services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import 'dart:developer' as devtools show log;
import '/services/env.dart' as env;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controller objects that connect between button and text field
  late final TextEditingController _email;
  late final TextEditingController _passwd;

  @override
  void initState() {
    _email = TextEditingController();
    _passwd = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _passwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: appTheme.green,
          title: const Text("Self Check Out Cart"),
        ),
        body: showPage()
        // body: Center(
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
        );
  }

  Widget showPage() {
    return Center(
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
                // final userCred =
                //     await FirebaseAuth.instance.signInWithEmailAndPassword(
                //   email: email,
                //   password: passwd,
                // );
                // devtools.log(userCred.toString());
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //   connectRoute,
                //   (route) => false,
                // );
                bool isLoggedIn = await Auth().login(context, email, passwd);
                // Auth().establishWebSocket(env.sock);
                if (!isLoggedIn) {
                  showAlertMassage(context, "Failed to log in");
                  return;
                }
                context.goNamed(connectRoute);
                // } on Exception catch (e) {
              } catch (e) {
                // TODO User not found, wrong Password
                // switch (e.code) {
                switch (e) {
                  case 'User-not-found':
                    devtools.log('User-not-found');
                    showAlertMassage(context, "User not found");
                    break;
                  case 'Email-not-found':
                    devtools.log('Email-not-found');
                    showAlertMassage(context, "Email not found");
                    break;
                  case 'Wrong-cred':
                    devtools.log('Wrong-cred');
                    showAlertMassage(context, "Wrong Credentials");
                    break;
                  default:
                    devtools.log('Error: $e');
                    showAlertMassage(context, "$e");
                    break;
                }
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
    );
  }
}
