import 'dart:io';

class ThumbnailObject {
  ThumbnailObject({this.image, this.isSelected});

  bool isSelected;
  final File image;

  void selectCategory() {
    print('select cat called');
    isSelected = !isSelected;
  }
}
