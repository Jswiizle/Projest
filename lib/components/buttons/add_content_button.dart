import 'package:flutter/material.dart';

class AddContentButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;

  AddContentButton({@required this.icon, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 45,
      height: 45,
      onPressed: onPressed,
      elevation: 4.0,
      color: Colors.white,
      child: icon,
      shape: CircleBorder(),
    );
  }
}
