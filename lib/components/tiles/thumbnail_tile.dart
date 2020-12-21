import 'package:flutter/material.dart';
import 'package:projest/models/objects/thumbnail_object.dart';

class ThumbnailTile extends StatelessWidget {
  ThumbnailTile({this.thumbnail, this.onTap});

  final Function onTap;
  final ThumbnailObject thumbnail;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        thumbnail.selectCategory();
        onTap();
      },
      child: Container(
        // height: 90,
        // width: 160,
        child: Container(
          child: ClipRRect(
            child: Image.file(thumbnail.image),
            borderRadius: BorderRadius.circular(10.0),
          ),
          decoration: BoxDecoration(
            border: Border.all(
                color: thumbnail.isSelected
                    ? Colors.lightBlue
                    : Colors.transparent,
                width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
