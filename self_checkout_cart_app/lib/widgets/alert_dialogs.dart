import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../widgets/all_widgets.dart';
// import 'package:flutter_g  en/gen_l10n/app_localizations.dart';

typedef Action = void Function();

Future<bool> showDialogWithWillPopScope({
  required BuildContext context,
  String? title,
  required String content,
  required List<ButtonArgs> buttons,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(content),
          actions: buttons.map((button) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop<bool>(button.value);
              },
              child: Text(button.text),
            );
          }).toList(),
        ),
      );
    },
  ).then((value) => value ?? false);
}

void showAlertMessage(BuildContext context, String message,
    {Action? onOk, Action? then}) {
  showDialogWithWillPopScope(
    context: context,
    title: "",
    content: message,
    buttons: [
      // CustomDialogButton(text: "OK", value: true),
    ],
  ).then((value) {
    if (then != null) then();
  });
}

Future<bool> customDialog({
  required BuildContext context,
  required String title,
  required List<ButtonArgs> buttons,
  String? message,
}) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message ?? ''),
        actions: buttons.map((button) {
          return CustomDialogButton(
            onPressed: () {
              Navigator.of(context).pop<bool>(button.value);
            },
            text: button.text,
          );
        }).toList(),
      );
    },
  ).then((value) => value ?? false);
}

class ButtonArgs {
  final String text;
  final bool value;
  final VoidCallback? onPressed;

  const ButtonArgs({
    required this.text,
    required this.value,
    this.onPressed,
  });
}

Future<void> showCustomDialog(
    BuildContext context, String title, String content, String buttonText) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('$title'),
        content: Text('$content'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('$buttonText'),
          ),
        ],
      );
    },
  );
}

// Future<bool> showQRDialog(BuildContext context, String id) {
//   return showDialogWithWillPopScope(
//     context: context,
//     title: 'Confirm QR',
//     content: 'Connecting to Cart $id',
//     buttons: [
//       CustomDialogButton<bool>(text: 'Confirm', value: true),
//       CustomDialogButton<bool>(text: 'Cancel', value: false),
//     ],
//   ).then((value) => value ?? false);
// }

// typedef Action = void Function();

void showAlertMassage(context, String message, {Action? onOk, Action? then}) {
  SchedulerBinding.instance.addPostFrameCallback(
    (_) => showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          // title: Text(AppLocalizations.of(context)!.errorDialogTitle),
          title: Text(""), //TODO app local
          content: Text(message),
          // actions: <Widget>[
          //   CustomButton(
          //     onPressed: () {
          //       if (onOk != null) onOk();
          //       Navigator.pop(context, 'OK');
          //     },
          //     // child: Text(AppLocalizations.of(context)!.ok),
          //     text: "ok",
          //   ),
          // ],
        ),
      ),
    ).then(
      (value) {
        if (then == null) return;
        then();
      },
    ),
  );
}

//TODO parametrize an alert

Future<bool> showQRDialog(BuildContext context, String id) {
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
//                                   local.authCustomDialogButtonText,
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
