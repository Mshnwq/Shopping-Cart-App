import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/custom_exceptions.dart';
import '../widgets/all_widgets.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // controller onbjects that connect between button and text field
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _passwd;
  late final TextEditingController _passwdConf;

  @override
  void initState() {
    _username = TextEditingController();
    _email = TextEditingController();
    _passwd = TextEditingController();
    _passwdConf = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _passwd.dispose();
    _passwdConf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: appTheme.green,
          title: const Text("Self Check Out Cart"),
        ),
        body: showPage(context)
        // body: Center(
        // child: FutureBuilder(
        //   future: Firebase.initializeApp(
        //     options: DefaultFirebaseOptions.currentPlatform,
        //   ),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasError) {
        //       switch (snapshot.connectionState) {
        //         // case ConnectionState.none:
        //         //   // TODO: Handle this case.
        //         //   break;
        //         // case ConnectionState.waiting:
        //         //   // TODO: Handle this case.
        //         //   break;
        //         // case ConnectionState.active:
        //         //   // TODO: Handle this case.
        //         // break;
        //         case ConnectionState.done:
        //           return showPage(context, appTheme);
        //         default:
        //           return const Center(child: CircularProgressIndicator());
        //       }
        //     } else {
        //       return const Text("call returns error :");
        //     }
        //   },
        // ),
        );
    // );
  }

  Widget showPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            textAlign: TextAlign.center,
            controller: _username,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Username',
            ),
          ),
          TextField(
            textAlign: TextAlign.center,
            controller: _email,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter Email',
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
          TextField(
            textAlign: TextAlign.center,
            controller: _passwdConf,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Confirm Password',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = _username.text;
              final email = _email.text;
              final passwd = _passwd.text;
              final passwdConf = _passwdConf.text;
              try {
                if (passwdConf == passwd) {
                  // bool isSuccess = await Auth().register(
                  // context, username, email, passwd);
                  bool isSuccess = true; // TODO email message
                  if (isSuccess) {
                    context.goNamed(connectRoute);
                  }
                } else {
                  throw const PassWordMismatchException();
                }
              } on PassWordMismatchException {
                showAlertMassage(context, "Passwords don't match");
              } catch (e) {
                // switch (e) {
                // case 'User-found':
                // devtools.log('Error: $e');
                // showAlertMassage(context, "User name in use");
                // break;
                // case 'Email-found':
                // devtools.log('Error: $e');
                // showAlertMassage(context, "Email in use");
                // break;
                // case 'Invalid-Email':
                // devtools.log('Error: $e');
                // showAlertMassage(context, "Invalid Email");
                // break;
                // default:
                devtools.log('Error: $e');
                showAlertMassage(context, "$e");
                // break;
                // }
              }
            },
            child: Text(
              'Register',
              // style: appTheme.getButtonTextStyle,
            ),
          ),
          TextButton(
            onPressed: () => context.goNamed(loginRoute),
            child: Text(
              'Log in',
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
