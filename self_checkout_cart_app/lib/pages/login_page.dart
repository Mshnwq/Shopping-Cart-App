import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import 'dart:async';
import 'dart:developer' as devtools show log;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // controller objects that connect between button and text field
  late final TextEditingController _email;
  late final TextEditingController _passwd;
  late bool isEmailMissing;
  late bool isPasswordMissing;

  @override
  void initState() {
    _email = TextEditingController();
    _passwd = TextEditingController();
    isEmailMissing = false;
    isPasswordMissing = false;
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
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/cart.png'),
                const SizedBox(height: 60),
                CustomTextField(
                  controller: _email,
                  hintText: 'Enter Email or Username',
                  errorText: isEmailMissing ? 'Email is required' : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwd,
                  hintText: 'Enter Password',
                  enableToggle: true,
                  errorText: isPasswordMissing ? 'Password is required' : null,
                ),
                const SizedBox(height: 20),
                CustomPrimaryButton(
                  onPressed: () async {
                    final String email = _email.text;
                    final String passwd = _passwd.text;

                    isEmailMissing = email.isEmpty;
                    isPasswordMissing = passwd.isEmpty;

                    if (isEmailMissing || isPasswordMissing) {
                      // showAlertMassage(
                      // context,
                      // "Please enter fill all entries.",
                      // );
                      // setState(() {}); // Trigger a rebuild to update the UI
                      showSuccessDialog(context, 'Success');
                      await Future.delayed(const Duration(milliseconds: 5000));
                      context.pop();
                      return;
                    }

                    try {
                      devtools.log("email $email");
                      devtools.log("pass $passwd");
                      showLoadingDialog(context);
                      bool completed = false;
                      final loginResult = await Future.any([
                        auth.login(context, email, passwd),
                        Future.delayed(Duration(seconds: 5)).then((_) {
                          if (!completed) {
                            throw TimeoutException(
                                'The authentication process took too long.');
                          }
                        }),
                      ]).then((_) {
                        // devtools.log('$_');
                        completed = true;
                        return _!;
                      });
                      if (loginResult) {
                        context.goNamed(connectRoute);
                      } else {
                        showAlertMassage(context, "Failed to log in");
                        return;
                      }
                    } on TimeoutException catch (e) {
                      showAlertMassage(context, e.toString());
                    } on Exception catch (e) {
                      String error = e.toString();
                      switch (error) {
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
                    } finally {
                      context.pop();
                    }
                  },
                  text: 'Log In',
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                InkWell(
                  onLongPress: () => context.goNamed(connectRoute),
                  child: TextButton(
                    onPressed: () => context.goNamed(registerRoute),
                    child: Text(
                      'Register',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.background,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
