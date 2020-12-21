import 'dart:io';

class BlipObject {
  BlipObject({
    this.id,
    this.description,
    this.imageUrl,
    this.url,
    this.title,
    this.temporaryImage,
  });

  String id;
  String description;
  String imageUrl;
  String url;
  String title;
  File temporaryImage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'imageUrl': imageUrl,
        'url': url,
        'title': title,
      };

  factory BlipObject.fromJson(Map<String, dynamic> parsedJson) {
    return BlipObject(
      description: parsedJson['description'],
      title: parsedJson['title'],
      imageUrl: parsedJson['imageUrl'],
      url: parsedJson['url'],
      temporaryImage: parsedJson['temporaryImage'],
      id: parsedJson['id'],
    );
  }
}
