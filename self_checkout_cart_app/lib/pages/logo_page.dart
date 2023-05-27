import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../widgets/all_widgets.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools show log;

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/cart.png'),
            const SizedBox(height: 20),
            Text(
              'Shop smarter... faster',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .background, // Set your desired text color here
                  ),
            ),
            const SizedBox(height: 120),
            CustomPrimaryButton(
              onPressed: () => context.goNamed(loginRoute),
              text: 'Log In',
              buttonHeight: 60,
            ),
            const SizedBox(height: 20),
            CustomPrimaryButton(
              onPressed: () => context.goNamed(registerRoute),
              text: 'Register',
              buttonHeight: 60,
            ),
          ],
        ),
      ),
    );
  }
}
