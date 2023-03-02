import 'package:go_router/go_router.dart';
import '../services/auth.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/env.dart' as env;
import '../constants/routes.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageeState();
}

class _ConnectPageeState extends State<ConnectPage> {
  @override
  Widget build(BuildContext context) {
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showLogOutDialog(context);
        if (shouldLogout) {
          // Auth().signOut();
          context.goNamed(logoRoute);
          // await FirebaseAuth.instance.signOut();
          // Navigator.of(context).pushNamedAndRemoveUntil(
          // loginRoute,
          // (_) => false,
          // );
        }
        return false;
      },
      child: Scaffold(
        endDrawer: const MenuBar(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), //height of appbar
          child: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            // backgroundColor: appTheme.green,
            title: Text(
              'Welcome {\$_username}',
              style: Theme.of(context).textTheme.titleLarge,
              // style: appTheme.setButtonTextStyle(22, 1.5),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                // onPressed: () => GoRouter.of(context).pushNamed(qrScanRoute),
                onPressed: () {
                  Auth().establishWebSocket();
                  context.goNamed(cartRoute);
                  // context.goNamed(qrScanRoute);
                },
                child: const Text('Scan QR code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
