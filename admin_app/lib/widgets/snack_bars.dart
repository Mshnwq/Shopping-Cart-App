import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
