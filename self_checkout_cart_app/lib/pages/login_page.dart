import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
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
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwd,
                  hintText: 'Enter Password',
                  enableToggle: true,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: () async {
                    final String email = _email.text;
                    final String passwd = _passwd.text;
                    try {
                      devtools.log("email $email");
                      devtools.log("pass $passwd");
                      bool isLoggedIn =
                          await auth.login(context, email, passwd);
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
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () => context.goNamed(logoRoute),
                //   child: Text(
                //     'Back',
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
