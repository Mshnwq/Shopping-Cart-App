import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:main_project/module/user.dart';
// import 'package:main_project/states/stream_state.dart';
// import '../../theme/themes.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef Action = void Function();

void showAlertMassage(context, String message, {Action? onOk, Action? then}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          // title: Text(AppLocalizations.of(context)!.errorDialogTitle),
          title: Text(""), //TODO app local
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (onOk != null) onOk();
                Navigator.pop(context, 'OK');
              },
              // child: Text(AppLocalizations.of(context)!.ok),
              child: Text("ok"),
            ),
          ],
        ),
      ),
    ).then((value) {
      if (then == null) return;
      then();
    });
  });
}

Future<bool> showLogOutDialog(BuildContext context) {
  // AppTheme appTheme =
  // Provider.of<ThemeProvider>(context, listen: false).getAppTheme();
  return showDialog<bool>(
    // conditional bool if phone return tap
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Confirm logging out'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            // style: appTheme.getButtonStyle,
            child: const Text('Log Out'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            // style: appTheme.getButtonStyle,
            child: const Text('Cancel'),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<bool> showCustomBoolDialog(
    BuildContext context, String title, String content, String buttonText) {
  return showDialog<bool>(
    // conditional bool if phone return tap
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('${title}'),
        content: Text('${content}'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            // style: appTheme.getButtonStyle,
            child: Text('${buttonText}'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            // style: appTheme.getButtonStyle,
            child: const Text('Cancel'),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<void> showCustomDialog(
    BuildContext context, String title, String content, String buttonText) {
  // AppTheme appTheme =
  // Provider.of<ThemeProvider>(context, listen: false).getAppTheme();
  return showDialog<void>(
    // conditional bool if phone return tap
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('${title}'),
        content: Text('${content}'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            // style: appTheme.getButtonStyle,
            child: Text('${buttonText}'),
          ),
        ],
      );
    },
  );
}

//TODO parametrize an alert

Future<bool> showQRDialog(BuildContext context, String id) {
  // AppTheme appTheme =
  // Provider.of<ThemeProvider>(context, listen: false).getAppTheme();
  return showDialog<bool>(
    // conditional bool if phone return tap
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm QR'),
        content: Text('Connecting to Cart $id'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            // style: appTheme.getButtonStyle,
            child: const Text('Confirm'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            // style: appTheme.getButtonStyle,
            child: const Text('Cancel'),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}

// void showLoadingDialog(BuildContext context) {
//   SchedulerBinding.instance.addPostFrameCallback((_) => showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) {
//         return WillPopScope(
//           // to prevent user from pop the loading dialog
//           onWillPop: () async => false,
//           child: const Center(
//               child: CircularProgressIndicator(
//             color: Colors.white,
//           )),
//         );
//       }));
// }

// typedef ActionBool = void Function(bool a);
// void showAuthenticationDialog(BuildContext context, {ActionBool? then}) {
//   AppTheme appTheme = context.read<ThemeProvider>().getAppTheme();
//   var local = AppLocalizations.of(context)!;
//   final TextEditingController controller = TextEditingController();
//   SchedulerBinding.instance.addPostFrameCallback((_) {
//     showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => Center(
//         child: Material(
//           elevation: 2,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
//           color: appTheme.cardColor,
//           child: WillPopScope(
//               onWillPop: () async => true,
//               child: Container(
//                 width: 259,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(23),
//                   color: appTheme.cardColor,
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Positioned(
//                         left: 20,
//                         top: 20,
//                         child: GestureDetector(
//                             child:
//                                 const Icon(Icons.keyboard_arrow_left_rounded),
//                             onTap: () {
//                               Navigator.pop(context, true);
//                             })),
//                     Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             local.authDialogTitle,
//                             style: const TextStyle(
//                               fontSize: 20,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 150,
//                             child: TextField(
//                               controller: controller,
//                               enabled: true,
//                               keyboardType: TextInputType.number,
//                               textAlign: TextAlign.center,
//                               cursorColor: Colors.white,
//                               decoration: InputDecoration(
//                                 hintText: local.authDialogInputFieldPlaceholder,
//                                 disabledBorder: const UnderlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.red)),
//                                 enabledBorder: const UnderlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.grey)),
//                                 focusedBorder: const UnderlineInputBorder(
//                                     borderSide:
//                                         BorderSide(color: Colors.white)),
//                                 border: const UnderlineInputBorder(),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: 120,
//                             height: 45,
//                             decoration: const BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(8.0)),
//                                 color: Color(0xFFd9d9d9)),
//                             child: TextButton(
//                                 style: ButtonStyle(
//                                   overlayColor:
//                                       MaterialStateProperty.all(Colors.black12),
//                                 ),
//                                 onPressed: () async {
//                                   logInManager.login(
//                                       context.read<User>(), controller.text);
//                                 },
//                                 child: Text(
//                                   local.authDialogButtonText,
//                                   style: const TextStyle(color: Colors.black87),
//                                 )),
//                           )
//                         ]),
//                   ],
//                 ),
//               )),
//         ),
//       ),
//     ).then((value) {
//       if (then == null) return;
//       then(value ?? true);
//     });
//   });
// }
