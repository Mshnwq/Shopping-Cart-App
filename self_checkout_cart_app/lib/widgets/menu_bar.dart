import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/routes.dart';
import '../widgets/all_widgets.dart';
import '../theme/theme_controller.dart';
import '../providers/mqtt_provider.dart';
import '../providers/auth_provider.dart';
import 'dart:developer' as devtools;

class MenuBar extends ConsumerWidget {
  const MenuBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Side menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.background,
                    ),
              )
              // image: DecorationImage(
              // fit: BoxFit.fill,
              // image: AssetImage('assets/images/cover.jpg'))),
              ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onLongPress: () => {context.goNamed(cartRoute)},
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              final shouldLogout = await customDialog(
                context: context,
                title: 'Log Out',
                message: 'Confirm logging out',
                buttons: [
                  const ButtonArgs(
                    text: 'Log Out',
                    value: true,
                  ),
                  const ButtonArgs(
                    text: 'Cancel',
                    value: false,
                  ),
                ],
              );
              if (shouldLogout) {
                // ref.read(mqttProvider).disconnect();
                ref.read(authProvider).logout();
                context.goNamed(logoRoute);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.chrome_reader_mode),
            title: const Text('About'),
            onTap: () => {showAboutDialog(context: context)},
          ),
          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text('FAQ\'s'),
            onTap: () => {showAboutDialog(context: context)},
          ),
          IconButton(
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  // theme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                  ThemeMode.light;
            },
            icon: Icon(
                // theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                Icons.light_mode),
          ),
        ],
      ),
    );
  }
}
