import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../widgets/all_widgets.dart';
// import 'package:flutter_g  en/gen_l10n/app_localizations.dart';
import 'dart:developer' as devtools;

typedef Action = void Function();

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
        actions: buttons.map(
          (button) {
            return CustomDialogButton(
              onPressed: () {
                Navigator.of(context).pop(button.value);
              },
              text: button.text,
            );
          },
        ).toList(),
      );
    },
  ).then((value) => value ?? false);
}

Future<bool> showCustomBoolDialog(
    BuildContext context, String title, String content, String buttonText) {
  return showDialog<bool>(
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

void showAlertMassage(context, String message, {Action? onOk, Action? then}) {
  SchedulerBinding.instance.addPostFrameCallback(
    (_) => showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          //TODO: title: Text(AppLocalizations.of(context)!.errorDialogTitle),
          title: Text(
            "Error",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: CustomDialogButton(
                onPressed: () {
                  if (onOk != null) onOk();
                  Navigator.pop(context, 'OK');
                },
                text: "ok",
              ),
            ),
          ],
        ),
      ),
      // ).then(
      //   (value) {
      //     if (then == null) return;
      //     then();
      //   },
      // ),
    ).then((value) => value ?? false),
  );
}

void showLoadingDialog(BuildContext context) {
  SchedulerBinding.instance.addPostFrameCallback(
    (_) => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          // to prevent user to pop the loading dialog
          onWillPop: () async => false,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        );
      },
    ),
  );
}

void showCustomLoadingDialog(BuildContext context, String title, String body,
    {int? durationInSeconds, double? boxSize}) {
  StreamController<int> countdownController = StreamController<int>();
  int remainingTime = durationInSeconds ?? 0;
  bool showCountdown = durationInSeconds != null;
  double dialogSize = boxSize ?? 250.0;

  if (showCountdown) {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
        countdownController.add(remainingTime);
      } else {
        timer.cancel();
        countdownController.close();
        // Navigator.of(context).pop();
      }
    });
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        // Prevent the user from popping the loading dialog
        onWillPop: () async => false,
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: dialogSize,
            height: dialogSize,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: dialogSize / 6),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: SizedBox(
                        height: 80.0,
                        width: 80.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 10.0,
                          // valueColor: AlwaysStoppedAnimation<Color>(
                          // Theme.of(context).colorScheme.secondary,
                          // ),
                        ),
                      ),
                    ),
                    if (showCountdown)
                      StreamBuilder<int>(
                        stream: countdownController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(color: Colors.red),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                  ],
                ),
                SizedBox(height: dialogSize / 8),
                Expanded(
                  child: Center(
                    child: Text(
                      body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

typedef ActionBool = void Function(bool a);
void showAuthenticationDialog(BuildContext context, {ActionBool? then}) {
  // var local = AppLocalizations.of(context)!;
  final TextEditingController controller = TextEditingController();
  SchedulerBinding.instance.addPostFrameCallback(
    (_) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) => Center(
          child: Material(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            // color: appTheme.cardColor,
            child: WillPopScope(
              onWillPop: () async => true,
              child: Container(
                width: 259,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  // color: appTheme.cardColor,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 20,
                      top: 20,
                      child: GestureDetector(
                        child: const Icon(Icons.keyboard_arrow_left_rounded),
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Logging in',
                          // local.authDialogTitle,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: controller,
                            enabled: true,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              // hintText: local.authDialogInputFieldPlaceholder,
                              hintText: 'Please Wait',
                              disabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              border: const UnderlineInputBorder(),
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 45,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: Color(0xFFd9d9d9)),
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.all(Colors.black12),
                            ),
                            onPressed: () {
                              // logInManager.login(
                              // context.read<User>(), controller.text);
                              // return true;
                              devtools.log("aaaaa");
                            },
                            child: Text(
                              // local.authCustomDialogButtonText,
                              'ssss',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).then(
        (value) {
          if (then == null) return;
          then(value ?? true);
        },
      );
    },
  );
}
