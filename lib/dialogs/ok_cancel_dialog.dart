import 'package:flutter/material.dart';


Future<bool> showOkCancelDialog(BuildContext context,
  String titleText,
  String messageText,
  {String okButtonText = 'Ok',
    String cancelButtonText = 'Cancel'}) async {
  return showDialog(context: context, builder: (BuildContext context) {
    return AlertDialog(
      title: Text(titleText),
      content: Text(messageText),
      actions: <Widget>[
        TextButton(
          child: Text(cancelButtonText),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: Text(okButtonText),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        )
      ],
    );
  });
}

