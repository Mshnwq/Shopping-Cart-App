// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:main_project/services/connectivity_serves.dart';

// Future<void> checkConnection(
//     ConnectivityStatus connectivityStatus, context) async {
//   SchedulerBinding.instance.addPostFrameCallback((_) {
//     if (connectivityStatus == ConnectivityStatus.offline) {
//       SnackBar snackBar = SnackBar(
//         duration: const Duration(days: 365),
//         backgroundColor: Colors.red[500],
//         content: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: const [
//             Icon(Icons.warning),
//             SizedBox(
//               width: 20,
//             ),
//             Text('No internet connection'),
//           ],
//         ),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else {
//       ScaffoldMessenger.of(context).clearSnackBars();
//     }
//   });
// }

// //NOTE: you may add a different type of notification like {Message, Warning, ...etc} to show different style for each type
// void showInAppNotification(RemoteMessage message, BuildContext context) {
//   SnackBar snackBar = SnackBar(
//       backgroundColor: Colors.blue,
//       content: Text(
//           "${message.notification?.title ?? ""} | ${message.notification?.body ?? ""}"));
//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }

void showSuccussSnackBar(context) {
  return SchedulerBinding.instance.addPostFrameCallback(
    (timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Coming Soon"),
          backgroundColor: Color.fromARGB(255, 118, 208, 121),
          action: SnackBarAction(
            label: 'dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    },
  );
}
