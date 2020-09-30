import 'package:flutter/material.dart';

class BlipObject {
  BlipObject(
      {this.blipId,
      this.description,
      this.imageUrl,
      this.url,
      this.title,
      this.temporaryImage});

  String blipId;
  String description;
  String imageUrl;
  String url;
  String title;
  Image temporaryImage;

  Map<String, dynamic> toJson() => {
        'blipId': blipId,
        'description': description,
        'imageUrl': imageUrl,
        'url': url,
        'title': title,
      };
}
