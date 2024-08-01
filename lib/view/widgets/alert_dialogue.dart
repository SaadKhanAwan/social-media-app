import 'package:flutter/material.dart';

class Dailgoue {
  static alertdialgue(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location  Disabled'),
          content:
              const Text('Please enable live location  to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
