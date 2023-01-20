import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/all_widgets.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import 'dart:developer' as devtools show log;

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  String? receiptKey;
  bool receiptKeyTextState = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    return Scaffold(
      // endDrawer: const MenuBar(),
      appBar: AppBar(
          // backgroundColor: appTheme.green,
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.goNamed(loginRoute),
              // style: appTheme.getButtonStyle,
              child: Text(
                'Log In',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
            ElevatedButton(
              onPressed: () => context.goNamed(registerRoute),
              // style: appTheme.getButtonStyle,
              child: Text(
                'Register',
                // style: appTheme.getButtonTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
