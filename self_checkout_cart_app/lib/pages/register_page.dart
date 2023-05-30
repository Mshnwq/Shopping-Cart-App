import 'dart:async';
import 'dart:convert';

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
  late bool isUserMissing;
  late bool isEmailMissing;
  late bool isPasswordMissing;
  late bool isPasswordConfMissing;

  @override
  void initState() {
    _username = TextEditingController();
    _email = TextEditingController();
    _passwd = TextEditingController();
    _passwdConf = TextEditingController();
    isUserMissing = false;
    isEmailMissing = false;
    isPasswordMissing = false;
    isPasswordConfMissing = false;
    super.initState();
    ref.read(authProvider);
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
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _username,
                  hintText: 'Username',
                  errorText: isUserMissing ? 'Username is required' : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _email,
                  hintText: 'Email',
                  isEmail: true,
                  errorText: isEmailMissing ? 'Email is required' : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwd,
                  hintText: 'Enter Password',
                  enableToggle: true,
                  errorText: isPasswordMissing ? 'Password is required' : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwdConf,
                  hintText: 'Confirm Password',
                  errorText: isPasswordConfMissing
                      ? 'Password Confirm is required'
                      : null,
                  enableToggle: true,
                ),
                const SizedBox(height: 20),
                CustomPrimaryButton(
                  onPressed: () async {
                    final user = _username.text;
                    final email = _email.text;
                    final passwd = _passwd.text;
                    final passwdConf = _passwdConf.text;

                    isUserMissing = user.isEmpty;
                    isEmailMissing = email.isEmpty;
                    isPasswordMissing = passwd.isEmpty;
                    isPasswordConfMissing = passwdConf.isEmpty;

                    if (isUserMissing ||
                        isEmailMissing ||
                        isPasswordMissing ||
                        isPasswordConfMissing) {
                      showAlertMassage(context, "Please Fill all entries");
                      setState(() {}); // Trigger a rebuild to update the UI
                      return;
                    }
                    try {
                      if (passwdConf == passwd) {
                        showLoadingDialog(context);
                        bool completed = false;
                        final isSuccess = await Future.any([
                          auth.register(context, user, email, passwd),
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
                          showSuccessDialog(context, 'Success');
                          await Future.delayed(
                              const Duration(milliseconds: 1500));
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
                      String error = json
                          .decode(
                            e.toString().substring('Exception:'.length),
                          )['detail']
                          .toString();
                      devtools.log(error);
                      showAlertMassage(context, error);
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
      ),
    );
  }
}
