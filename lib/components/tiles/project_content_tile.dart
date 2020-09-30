import 'package:flutter/material.dart';
import 'package:projest/models/objects/blip_object.dart';

class ProjectContentTile extends StatelessWidget {
  final BlipObject blipObject;
  final Function onTap;
  final Function onSlideToLeft;

  ProjectContentTile({this.blipObject, this.onTap, this.onSlideToLeft});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onHorizontalDragEnd: onSlideToLeft,
      child: Card(
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(8),
          child: blipObject.temporaryImage,
        ),
      ),
    );
  }
}
