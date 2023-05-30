import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/custom_exceptions.dart';
import '../providers/auth_provider.dart';
import '../widgets/all_widgets.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools;

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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
    final auth = ref.watch(authProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/cart.png'),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _username,
                hintText: 'Username',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _email,
                hintText: 'Email',
                isEmail: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _passwd,
                hintText: 'Enter Password',
                enableToggle: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _passwdConf,
                hintText: 'Confirm Password',
                enableToggle: true,
              ),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                onPressed: () async {
                  final username = _username.text;
                  final email = _email.text;
                  final passwd = _passwd.text;
                  final passwdConf = _passwdConf.text;
                  if (email.isEmpty ||
                      passwd.isEmpty ||
                      username.isEmpty ||
                      passwdConf.isEmpty) {
                    showAlertMassage(context, "Please Fill all entries");
                    return;
                  }
                  try {
                    if (passwdConf == passwd) {
                      showLoadingDialog(context);
                      bool completed = false;
                      final isSuccess = await Future.any([
                        auth.register(context, username, email, passwd),
                        Future.delayed(Duration(seconds: 5)).then((_) {
                          if (!completed) {
                            throw TimeoutException(
                                'The authentication process took too long.');
                          }
                        }),
                      ]).then((_) {
                        devtools.log('$_');
                        completed = true;
                        return _!;
                      });
                      if (isSuccess) {
                        context.goNamed(connectRoute);
                      } else {
                        showAlertMassage(context, "Failed to register");
                        return;
                      }
                    } else {
                      throw const PassWordMismatchException();
                    }
                  } on PassWordMismatchException {
                    showAlertMassage(context, "Passwords don't match");
                  } catch (e) {
                    switch (e) {
                      case 'User-found':
                        devtools.log('Error: $e');
                        showAlertMassage(context, "User name in use");
                        break;
                      case 'Email-found':
                        devtools.log('Error: $e');
                        showAlertMassage(context, "Email in use");
                        break;
                      case 'Invalid-Email':
                        devtools.log('Error: $e');
                        showAlertMassage(context, "Invalid Email");
                        break;
                      default:
                        devtools.log('Error: $e');
                        showAlertMassage(context, "$e");
                        break;
                    }
                  } finally {
                    context.pop();
                  }
                },
                text: 'Register',
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => context.goNamed(loginRoute),
                child: Text(
                  'Log in',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
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
      ),
    );
  }
}
