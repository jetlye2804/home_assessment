import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showDoneDialog(BuildContext context, String title, String subtitle) {
  if (Platform.isIOS || Platform.isMacOS) {
    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(subtitle),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        contentPadding:
            const EdgeInsets.only(top: 16, left: 25, right: 32, bottom: 0),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              'Got it',
            ),
          ),
        ],
      ),
    );
  }
}

void showConfirmationDialog(BuildContext context, String title, String subtitle,
    Function() proceedFunction) {
  if (Platform.isIOS || Platform.isMacOS) {
    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(subtitle),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    proceedFunction();
                  },
                ),
              ],
            ));
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        contentPadding:
            const EdgeInsets.only(top: 16, left: 25, right: 32, bottom: 0),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              'Got it',
            ),
          ),
        ],
      ),
    );
  }
}
