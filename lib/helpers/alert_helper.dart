import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AlertHelper {
  AlertHelper(
      {@required this.title,
      @required this.body,
      this.choice1,
      this.choice2,
      this.c1,
      this.c2});

  final String title;
  final String body;
  final String choice1;
  final String choice2;
  final Function c1;
  final Function c2;

  void generateAlert(BuildContext context) {
    if (Platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
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

  void generateChoiceAlert(BuildContext context) {
    if (Platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text(choice1),
                onPressed: c1,
              ),
              FlatButton(
                child: Text(choice2),
                onPressed: c2,
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text(choice1),
                onPressed: c1,
              ),
              FlatButton(
                child: Text(choice2),
                onPressed: c2,
              )
            ],
          );
        },
      );
    }
  }
}
